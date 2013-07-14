# MiniTest sets an at_exit that we dont want to run
# this is stupid so we have this hack to fix it
# This bug is talked about here https://groups.google.com/forum/#!msg/cukes/VoLUFDbiNdc/7QmeelIyBg4J
# I hate this so please lets find a better solution -- Jared
require 'minitest/unit'
MiniTest::Unit.class_variable_set(:@@installed_at_exit,true)
