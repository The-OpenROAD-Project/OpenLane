// Copyright 2022 Arman Avetisyan
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

`default_nettype none
module def_test (
    input wire in,
    output out,
    output tied_to_zero,
    output manufacturing_grid_missaligned_pin
    );
    // We tie this to one, so if def's pin is tied to zero, it will LVS error
    assign tied_to_zero = 1;
    assign manufacturing_grid_missaligned_pin = 1;

    assign out = !in;

endmodule
