#!/usr/bin/env ruby

STDERR.sync = STDOUT.sync = true

require 'bundler'
Bundler.require(:default, :cli)

require File.expand_path('../../lib/cucub-vm.rb', __FILE__)
require File.expand_path('../../lib/vm/servolux.rb', __FILE__)
require File.expand_path('../../lib/vm/cli.rb', __FILE__)

Cucub::VM::CLI.start
