#!/usr/local/bin/ruby
#
# XCode project management script for Zombie Hero : Revenge of Kiki (iOS game)
# It use xcodeproj to manage all around stuff
#
# author: @haxpor
# version: 0.1
#

require 'xcodeproj'
require 'colorize'

def printGroup(groups, level)
    #puts "-Processing level #{level}-"

    # if the groups itself is nil so there's nothing, then return immediately
    if groups.nil?
        return nil
    end

    groups.each do |val|
        # if its children is empty, then print
        # if val.groups.empty?
            # indent for children
            for l in 1..level
                print "| ".red
            end

            # print group name
            puts "#{val.display_name}"

        # if it has children, then do it recursively
        #else
            printGroup(val.groups, level + 1)
        #end
    end
    
    return nil
end

xcode_project_path = '/Users/haxpor/Data/Projects/ZombieHero/zombie-hero/'
xcode_project_name = 'ZombieHero.xcodeproj'

project_file = "#{xcode_project_path}#{xcode_project_name}"

puts "Processing #{project_file} ..."

project = Xcodeproj::Project.open(project_file)

#dialogue_file = project.new_file('tutorial-1.zhd')

printGroup(project.groups, 0)
