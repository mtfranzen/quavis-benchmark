#!/bin/bash

git submodule update --remote
(cd quavis/cube && cmake . && make)
(cd quavis/spherical && cmake . && make)
