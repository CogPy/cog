'''Cog Environment

Copyright (c) Kristoffer Nordstroem, All rights reserved.

This library is free software; you can redistribute it and/or
modify it under the terms of the GNU Lesser General Public
License as published by the Free Software Foundation; either
version 3.0 of the License, or (at your option) any later version.

This library is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public
License along with this library.

'''

import sys

from .CogConfiguration import CogConfiguration
from .Cog import Cog
from .ModelsimCompiler import ModelsimCompiler


class CogEnv(object):
    '''
    Setting up the Cog environment.
    Parse command-line and conf.ini file if available.
    '''
    def __init__(self):
        try:
            sys.argv.index('-f')
        except ValueError:
            self.force_compile = False
        else:
            self.force_compile = True

        try:
            sys.argv.index('--debug')
        except ValueError:
            self._debug_info = False
        else:
            self._debug_info = True

        self.cfg = CogConfiguration()
        self.coginst = None
        if self.cfg.TB_ENTITY:
            self.factory()


    def factory(self):
        self.coginst = Cog(top=self.cfg.TB_FILE, debug=self._debug_info)
        for i in self.cfg.BASEDIR:
            self.coginst.add_lib(i, 'work')

        # Compiler factory
        if self.cfg.MODELSIM:
            self.coginst.comp = ModelsimCompiler(self.cfg.MODELSIM)

        self.coginst.comp.compile_options = self.cfg.COMPILE_OPTIONS


    def compile_all(self):
        self.coginst.load_cache()
        self.coginst.parse()
        if not self.force_compile:
            self.coginst.import_compile_times(self.coginst.comp.get_libs_content(self.coginst.libs))
        self.coginst.gen_tree()
        self.coginst.comp.compile_all_files(self.coginst.col)
        self.coginst.save_cache()


    def compile_file(self):
        self.coginst.load_cache()
        self.coginst.parse()
        if not self.force_compile:
            self.coginst.import_compile_times(self.coginst.comp.get_libs_content(self.coginst.libs))
        self.coginst.gen_tree(self.coginst.top_file)
        self.coginst.comp.compile_all_files(self.coginst.col)
        self.coginst.save_cache()


    def run_simulation_gui(self):
        return self.coginst.comp.run_simulation_gui(self.cfg.TB_ENTITY, self.cfg.SIM_OPTIONS)

    def run_simulation(self):
        return self.coginst.comp.run_simulation(self.cfg.TB_ENTITY, self.cfg.SIM_OPTIONS)
