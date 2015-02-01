# -*- coding: utf-8  -*-

# This is an automatically generated file. You can find more configuration
# parameters in 'config.py' file.

# The family of sites to work on by default.
#
# ‘site.py’ imports ‘families/xxx_family.py’, so if you want to change
# this variable, you need to use the name of one of the existing family files
# in that folder or write your own, custom family file.
#
# For ‘site.py’ to be able to read your custom family file, you must
# save it to ‘families/xxx_family.py’, where ‘xxx‘ is the codename of the
# family that your custom ‘xxx_family.py’ family file defines.
#
# You can also save your custom family files to a different folder. As long
# as you follow the ‘xxx_family.py’ naming convention, you can register your
# custom folder in this configuration file with the following global function:
#
#   register_families_folder(folder_path)
#
# Alternatively, you can register particular family files that do not need
# to follow the ‘xxx_family.py’ naming convention using the following
# global function:
#
#   register_family_file(family_name, file_path)
#
# Where ‘family_name’ is the family code (the ‘xxx’ in standard family file
# names) and ‘file_path’ is the absolute path to the target family file.
#
# If you use either of these functions to define the family to work on by
# default (the ‘family’ variable below), you must place the function call
# before the definition of the ‘family’ variable.

import ConfigParser
settings = ConfigParser.ConfigParser()
settings.read('../../configs/settings.ini')

family_files['hitchwiki'] = 'http://' + settings.get('general', 'domain') + '/en/api.php'

# TODO: Implement proper hitchwiki family file
# register_families_folder('families')

family = 'hitchwiki'

# The language code of the site we're working on.
mylang = 'en'

# The dictionary usernames should contain a username for each site where you
# have a bot account. If you have a unique username for all languages of a
# family , you can use '*'
usernames['hitchwiki']['en'] = u'Hitchbot'

put_throttle = 0

del ConfigParser
del settings