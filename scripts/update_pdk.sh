#!/bin/bash
echo "pulling the subtree"
git subtree pull --prefix pdks/ef-skywater-s8 https://vault.efabless.com/ef-pdk/ef-skywater-s8.git dev --squash

