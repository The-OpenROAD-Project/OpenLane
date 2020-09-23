"""
Train a ML model to predict cells based on vias location

Name: Tri Minh Cao
Email: tricao@utdallas.edu
Date: October 2016
"""

import pickle
import random
import os
from def_parser import *
from lef_parser import *
import util
from sklearn.linear_model import LogisticRegression
import numpy as np
import plot_layout

FEATURE_LEN = 21


def save_data_pickle(dataset, filename):
    # pickle the merged data
    # filename = "./merged_data/freepdk45_10_17_16.pickle"
    try:
        with open(filename, 'wb') as f:
            pickle.dump(dataset, f, pickle.HIGHEST_PROTOCOL)
    except Exception as e:
        print('Unable to save data to', filename, ':', e)


def merge_data(data_folder, num_cells):
    """
    Read from data pickle files, and merge
    :return:
    """
    random.seed(12345)

    all_samples = []
    all_labels = []
    pickle_files = os.listdir(data_folder)
    for file in pickle_files:
        pickle_file = os.path.join(data_folder, file)
        data = load_data_pickle(pickle_file)
        # REMOVE
        # pickle_file = os.path.join(data_folder, file)
        # try:
        #     with open(data_folder, 'rb') as f:
        #         dataset = pickle.load(f)
        # except Exception as e:
        #     print('Unable to read data from', pickle_file, ':', e)
        all_samples.extend(data[0])
        all_labels.extend(data[1])

    all_dataset = (all_samples, all_labels)
    dataset = {}
    dataset['AND2X1'] = []
    dataset['INVX1'] = []
    dataset['INVX8'] = []
    dataset['NAND2X1'] = []
    dataset['NOR2X1'] = []
    dataset['OR2X1'] = []

    choices = [i for i in range(len(all_samples))]
    random.shuffle(choices)
    for idx in choices:
        features = all_samples[idx]
        label = all_labels[idx]
        if len(dataset[label]) < num_cells:
            dataset[label].append(features)
        cont = False
        for each_macro in dataset:
            if len(dataset[each_macro]) < num_cells:
                cont = True
        if not cont:
            break

    for each_macro in dataset:
        print (each_macro)
        print (len(dataset[each_macro]))

    # should return the merged data set
    return dataset


def train_model(dataset, data_len, num_to_label):
    """
    Method to train model
    :param dataset: dataset
    :param data_len: total length of training set
    :return: trained model
    """
    all_dataset = np.ndarray(shape=(data_len, FEATURE_LEN),
                               dtype=np.int32)
    all_label = np.ndarray(data_len,
                             dtype=np.int32)
    current_size = 0
    num_selected = [0, 0, 0, 0, 0, 0]
    while current_size < data_len:
        choice = random.randrange(6) # we have 6 types of cells
        cur_label = num_to_label[choice]
        cur_idx = num_selected[choice]
        cur_data = dataset[cur_label][cur_idx]
        all_dataset[current_size, :] = np.array(dataset[cur_label][cur_idx],
                                                  dtype=np.int32)
        all_label[current_size] = choice
        current_size += 1
        num_selected[choice] += 1

    # shuffle the dataset
    random.seed(6789)
    all_dataset, all_label = util.randomize(all_dataset, all_label)
    num_train = int(0.85 * data_len)

    #print(max(all_label))

    test_dataset = all_dataset[num_train:]
    test_label = all_label[num_train:]
    train_dataset = all_dataset[:num_train]
    train_label = all_label[:num_train]

    # train a logistic regression model
    regr = LogisticRegression()
    X_train = train_dataset
    y_train = train_label
    X_test = test_dataset
    y_test = test_label

    regr.fit(X_train, y_train)
    score = regr.score(X_test, y_test)
    pred_labels = regr.predict(X_test)
    print(pred_labels[:100])
    print(score)

    # Save the trained model for later use
    # filename = "./trained_models/logit_model_103116.pickle"
    # save_data_pickle(regr, filename)
    # return the trained model
    return regr, X_train, y_train, X_test, y_test


def predict_cell(candidates, row, model, lef_data, std_cells):
    """
    Use the trained model to choose the most probable cell from via groups.
    :param candidates: 2-via and 3-via groups that could make a cell
    :return: a tuple (chosen via group, predicted cell name)
    """
    # possibly I can use the current method of testing the width of each cell
    # margin = 350
    # dataset = np.ndarray(shape=(len(candidates), FEATURE_LEN),
    #                      dtype=np.float32)
    scores = [-100 for i in range(len(candidates))]
    for i in range(len(candidates)):
        if candidates[i] != -1:
            features = []
            each_group = candidates[i]
            # width = std_cells[2]
            left_margin = std_cells[i][-1]
            # for left_margin in range(50, 800, 50):
            left_pt = [each_group[0][0][0] - left_margin, CELL_HEIGHT * row]
            # width = each_group[-1][0][0] - left_pt[0] + margin
            num_vias = len(each_group)
            features.append(num_vias)
            x_bound = left_pt[0]
            y_bound = left_pt[1]
            # NOTE: some cell has 4 vias
            # We suppose maximum vias in a cell is 4
            for each_via in each_group:
                x_loc = each_via[0][0] - x_bound
                y_loc = each_via[0][1] - y_bound
                # features.append(x_loc)
                features.append(y_loc)
                # add via type
                features.append(each_via[3])
            # if there are only two vias, then there are no via3
            if num_vias < 4:
                temp = [-1 for i in range((4 - num_vias) * 2)]
                features.extend(temp)
            # add the distance between vias
            for i in range(num_vias - 1):
                for j in range(i + 1, num_vias):
                    x_dist = each_group[j][0][0] - each_group[i][0][0]
                    y_dist = each_group[j][0][1] - each_group[i][0][1]
                    features.append(x_dist)
                    features.append(y_dist)
            # add extra features in case of having less vias
            if num_vias < 4:
                if num_vias == 1:
                    remain_dists = 2 * int(util.nCr(4, 2))
                else:
                    remain_dists = 2 * (int(util.nCr(4, 2) - util.nCr(num_vias, 2)))
                temp = [0 for i in range(remain_dists)]
                features.extend(temp)
            # do predict
            dataset = np.array(features, dtype=np.int32)
            # print(dataset)
            X_test = dataset.reshape(1, FEATURE_LEN)
            result = model.decision_function(X_test)
            result = result[0]
            # print(each_group)
            # print(left_margin)
            print(labels[i])
            print(features)
            print(result)
            # print()
            features = []
            if result[i] == max(result):
                return candidates[i], i
            # scores[i] = result[i]
    # return the best score
    # print(scores)
    # max_score = -100
    # best_choice = -1
    # for i in range(len(candidates)):
    #     if scores[i] > max_score:
    #         best_choice = i
    #         max_score = scores[i]
    # return candidates[best_choice], best_choice

    # possible_candidates = []
    # for i in range(len(candidates)):
    #     if candidates[i] != -1:
    #         possible_candidates.append(i)
    #         dataset = np.ndarray(shape=(1, img_height, img_width),
    #                              dtype=np.float32)
    #         each_group = candidates[i]
    #         left_pt = [each_group[0][0][0] - margin, CELL_HEIGHT * row]
    #         width = each_group[-1][0][0] - left_pt[0] + margin
    #         # print (width)
    #         img_file = plot_window(left_pt, width, CELL_HEIGHT, each_group, lef_data)
    #         # print (img_file)
    #         image_data = img_util.load_image(img_file)
    #         # print (image_data.shape)
    #         dataset[0, :, :] = image_data
    #         X_test = dataset.reshape(dataset.shape[0], img_shape)
    #         result = model.decision_function(X_test)
    #         result = result[0]
    #         # print (result)
    #         # check for result
    #         if result[i] == max(result):
    #             return candidates[i], i
    # # if we cannot find a solution, randomly select a choice
    # choice = random.choice(possible_candidates)
    # return candidates[choice], choice


def predict_row():
    # FIXME: restructure this method
    # We can load the trained model
    pickle_filename = "./trained_models/logit_model_101716.pickle"
    logit_model = load_data_pickle(pickle_filename)

    labels = {0: 'and2', 1: 'invx1', 2: 'invx8', 3: 'nand2', 4: 'nor2',
              5: 'or2'}
    cell_labels = {'AND2X1': 'and2', 'INVX1': 'invx1', 'NAND2X1': 'nand2',
                   'NOR2X1': 'nor2', 'OR2X1': 'or2', 'INVX8': 'invx8'}

    # process
    components = util.sorted_components(def_parser.diearea[1], CELL_HEIGHT,
                                        def_parser.components.comps)
    num_rows = len(components)
    # print the sorted components
    correct = 0
    total_cells = 0
    predicts = []
    actuals = []
    # via_groups is only one row
    # for i in range(len(via1_sorted)):
    for i in range(0, 1):
        via_groups = util.group_via(via1_sorted[i], 3, MAX_DISTANCE)
        visited_vias = [] # later, make visited_vias a set to run faster
        cells_pred = []
        for each_via_group in via_groups:
            first_via = each_via_group[0][0]
            # print (first_via)
            if not first_via in visited_vias:
                best_group, prediction = predict_cell(each_via_group, i,
                                                      logit_model, lef_parser)
                print (best_group)
                print (labels[prediction])
                cells_pred.append(labels[prediction])
                for each_via in best_group:
                    visited_vias.append(each_via)
                    # print (best_group)
                    # print (labels[prediction])

        print (cells_pred)
        print (len(cells_pred))

        actual_comp = []
        actual_macro = []
        for each_comp in components[i]:
            actual_comp.append(cell_labels[each_comp.macro])
            actual_macro.append(each_comp.macro)
        print (actual_comp)
        print (len(actual_comp))

        num_correct, num_cells = predict_score(cells_pred, actual_comp)

        correct += num_correct
        total_cells += num_cells
        predicts.append(cells_pred)
        actuals.append(actual_comp)

        print ()

    print (correct)
    print (total_cells)
    print (correct / total_cells * 100)


def load_data_pickle(filename):
    try:
        with open(filename, 'rb') as f:
            dataset = pickle.load(f)
    except Exception as e:
        print('Unable to read data from', filename, ':', e)
    return dataset


def old_main_class():
    num_cells_required = 900
    # merge_data()
    # load data from selected pickle
    set_filename = "./merged_data/selected_10_17_16.pickle"
    dataset = load_data_pickle(set_filename)

    # build the numpy array
    label_to_num = {'AND2X1': 0, 'INVX1': 1, 'INVX8': 2, 'NAND2X1': 3,
                    'NOR2X1': 4, 'OR2X1': 5}

    num_to_label = {0: 'AND2X1', 1: 'INVX1', 2: 'INVX8', 3: 'NAND2X1',
                    4: 'NOR2X1', 5: 'OR2X1'}

    # train_model()

    #######
    # DO SOME PREDICTION
    def_path = './libraries/layout_freepdk45/c880a.def'
    def_parser = DefParser(def_path)
    def_parser.parse()
    scale = def_parser.scale

    lef_file = "./libraries/FreePDK45/gscl45nm.lef"
    lef_parser = LefParser(lef_file)
    lef_parser.parse()

    print ("Process file:", def_path)
    CELL_HEIGHT = int(float(scale) * lef_parser.cell_height)
    all_via1 = util.get_all_vias(def_parser, via_type="M2_M1_via")
    # print (all_via1)
    # sort the vias by row
    via1_sorted = util.sort_vias_by_row(def_parser.diearea[1], CELL_HEIGHT, all_via1)

    MAX_DISTANCE = 2280 # OR2 cell width, can be changed later

    # predict_row()


    ################
    # new section
    # FIXME: need to build the netlist


    # test the image-based method

    ##############
    # List of standard cells
    std_cell_info = {}
    # info includes (min num vias, max num vias, width,
    #  distance from left boundary to first pin)
    # I wonder if max num vias should be used, actually I don't know what is the
    # maximum number of vias, but I guess +1 is fine.
    # 0 is and2, 1 is invx1, etc.
    std_cell_info[0] = (3, 4, 2280, 295)
    std_cell_info[1] = (2, 3, 1140, 315)
    std_cell_info[2] = (2, 3, 2660, 695)
    std_cell_info[3] = (3, 4, 1520, 90)
    std_cell_info[4] = (3, 4, 1520, 315)
    std_cell_info[5] = (3, 4, 2280, 695)


def get_candidates(first_via_idx, via_list, std_cells):
    """
    Generate a list of candidates from the first via.
    Each standard cell will be considered for candidates.
    If the standard cell cannot be placed there, the value is -1,
     otherwise, it will be a list of vias.
    :param first_via_idx: first via index in the via_list
    :param via_list: the list of all vias (in a row)
    :param std_cells: a list that stores information of std cells
    :return: a list of groups of vias, or -1
    """
    # candidates = [-1 for i in range(len(std_cells))]
    candidates = []
    first_via = via_list[first_via_idx]
    # print (first_via)
    first_via_x = first_via[0][0]
    for i in range(len(std_cells)):
        cell_width = std_cells[i][2]
        min_vias = std_cell_info[i][0]
        max_vias = std_cells[i][1]
        pin_left_dist = std_cells[i][3]
        boundary = first_via_x + cell_width - pin_left_dist
        # possible vias contain the vias inside the boundary
        possible_vias = [first_via]
        for j in range(first_via_idx + 1, len(via_list)):
            if via_list[j][0][0] <= boundary:
                possible_vias.append(via_list[j])
            else:
                break
        # check the candidate against cell info
        if len(possible_vias) > max_vias or len(possible_vias) < min_vias:
            candidates.append(-1)
            # continue
        else:
            if possible_vias not in candidates:
                candidates.append(possible_vias)
    print(candidates)
    print(len(candidates))
    return candidates


def get_inputs_outputs(def_info):
    """
    Method to get all inputs and outputs nets from a DEF file.
    :param def_info: def info (already parsed).
    :return: inputs and outputs
    """
    pins = def_parser.pins.pins
    inputs = []
    outputs = []
    for each_pin in pins:
        pin_name = each_pin.name
        direction = each_pin.direction.lower()
        if direction == 'input':
            inputs.append(pin_name)
        elif direction == 'output':
            outputs.append(pin_name)
    return inputs, outputs


# Main Class
if __name__ == '__main__':
    random.seed(12345)
    # CONSTANTS
    label_to_num = {'AND2X1': 0, 'INVX1': 1, 'INVX8': 2, 'NAND2X1': 3,
                    'NOR2X1': 4, 'OR2X1': 5}

    num_to_label = {0: 'AND2X1', 1: 'INVX1', 2: 'INVX8', 3: 'NAND2X1',
                    4: 'NOR2X1', 5: 'OR2X1'}

    # merge the data
    pickle_folder = './training_data/'
    dataset = merge_data(pickle_folder, 1100)

    # study the data
    # and2_data = dataset['AND2X1']
    # print(and2_data[:50])

    # pickle the merged data
    set_filename = "./merged_data/selected_11_03_16_less_feats.pickle"
    # save_data_pickle(dataset, set_filename)

    # train the model
    regr_model, X_train, y_train, X_test, y_test = train_model(dataset, 5500, num_to_label)
    save_data_pickle(regr_model, './trained_models/logit_110316_no_x.pickle')

    # study the test set
    for i in range(1, 100):
        print(num_to_label[y_test[i:i+1][0]])
        print(X_test[i:i+1])
        print(regr_model.decision_function(X_test[i:i+1]))
        print()

    # make up some cases here and see the result
    makeup = []
    # makeup.append([3, 190, 1710, 0, 950, 1710, 0, 1140, 1330, 1, -1, -1, -1])
    # no input/output data

    # makeup.append([3, 190+400, 1710, -1, 950+400, 1710, -1, 1140+400, 1330, -1, -1, -1, -1])
    # labels = []
    # labels.append(3)
    # X_makeup = np.array(makeup, dtype=np.int32)
    # for i in range(len(makeup)):
    #     print(num_to_label[labels[i]])
    #     print(X_makeup[i:i+1])
    #     print(regr_model.decision_function(X_makeup[i:i+1]))
    #     print(num_to_label[regr_model.predict(X_makeup[i:i+1])[0]])
    #     print()

    # load the model
    # model_file = './trained_models/logit_110316_no_x.pickle'
    # regr_model = load_data_pickle(model_file)


    #######
    # PREDICTION
    # get information from DEF and LEF files
    def_path = './libraries/layout_freepdk45/c432.def'
    def_parser = DefParser(def_path)
    def_parser.parse()
    scale = def_parser.scale

    lef_file = "./libraries/FreePDK45/gscl45nm.lef"
    lef_parser = LefParser(lef_file)
    lef_parser.parse()

    print ("Process file:", def_path)
    CELL_HEIGHT = int(float(scale) * lef_parser.cell_height)
    all_via1 = util.get_all_vias(def_parser, via_type="M2_M1_via")
    # print (all_via1[:50])

    # build the net_via dictionary
    nets = def_parser.nets.nets
    # initialize the nets_via_dict
    nets_vias_dict = {}
    for net in nets:
        net_name = net.name
        nets_vias_dict[net_name] = []
    # add vias to nets_dict
    for each_via in all_via1:
        net = each_via[2]
        nets_vias_dict[net].append(each_via)

    # sort the vias by row
    via1_sorted = util.sort_vias_by_row(def_parser.diearea[1], CELL_HEIGHT, all_via1)

    # add inputs and outputs from the design to via info
    inputs, outputs = get_inputs_outputs(def_parser)
    # print(inputs)
    # print(outputs)
    for each_in in inputs:
        for each_via in nets_vias_dict[each_in]:
            each_via[3] = 0
    for each_out in outputs:
        for each_via in nets_vias_dict[each_out]:
            each_via[3] = 1

    # get candidates
    labels = {0: 'and2', 1: 'invx1', 2: 'invx8', 3: 'nand2', 4: 'nor2',
              5: 'or2'}
    cell_labels = {'AND2X1': 'and2', 'INVX1': 'invx1', 'NAND2X1': 'nand2',
                   'NOR2X1': 'nor2', 'OR2X1': 'or2', 'INVX8': 'invx8'}

    ##############
    # List of standard cells
    std_cell_info = {}
    # info includes (min num vias, max num vias, width,
    #  distance from left boundary to first pin)
    # I wonder if max num vias should be used, actually I don't know what is the
    # maximum number of vias, but I guess +1 is fine.
    # 0 is and2, 1 is invx1, etc.
    std_cell_info[0] = (3, 4, 2280, 295)
    std_cell_info[1] = (2, 3, 1140, 315)
    std_cell_info[2] = (2, 3, 2660, 695)
    std_cell_info[3] = (3, 4, 1520, 90)
    std_cell_info[4] = (3, 4, 1520, 315)
    std_cell_info[5] = (3, 4, 2280, 695)
    # find the sorted components
    components = sorted_components(def_parser.diearea[1], CELL_HEIGHT,
                                   def_parser.components.comps)
    correct = 0
    total_cells = 0
    predicts = []
    actuals = []
    # via_groups is only one row
    # for i in range(len(via1_sorted)):
    for i in range(0, 1):
        print ('Process row', (i + 1))
        visited_vias = [] # later, make visited_vias a set to run faster
        cells_pred = []
        via_idx = 3
        while via_idx < len(via1_sorted[i]):
        # while via_idx < 3:
            # choosing candidates
            candidates = get_candidates(via_idx, via1_sorted[i], std_cell_info)
            best_group, prediction = predict_cell(candidates, i, regr_model,
                                                  lef_parser, std_cell_info)
            via_idx += len(best_group)
            print(best_group)
            print(labels[prediction])
            # cells_pred.append(labels[prediction])
            # for each_via in best_group:
            #     visited_vias.append(each_via)

        """
        print (cells_pred)
        print (len(cells_pred))

        actual_comp = []
        actual_macro = []
        for each_comp in components[i]:
            actual_comp.append(cell_labels[each_comp.macro])
            actual_macro.append(each_comp.macro)
        print (actual_comp)
        print (len(actual_comp))

        # check predictions vs actual cells
        # for i in range(len(actual_comp)):
        #     if cells_pred[i] == actual_comp[i]:
        #         correct += 1
        num_correct, num_cells = predict_score(cells_pred, actual_comp)

        correct += num_correct
        total_cells += num_cells
        predicts.append(cells_pred)
        actuals.append(actual_comp)

        print ()

    print (correct)
    print (total_cells)
    print (correct / total_cells * 100)
    """

