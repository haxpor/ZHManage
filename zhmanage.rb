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

def printGroup(groups, level, isPrintChildren)

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
            print "#{val.display_name}"
            puts "/".yellow

            # print its children if needed
            if isPrintChildren
                unless val.children.objects.empty?
                    val.children.objects.each do |child|
                        # indent for child
                        for l in 1..level+1
                            print ". ".blue
                        end

                        # print child
                        puts "#{child.display_name}"
                    end
                end
            end

        # if it has children, then do it recursively
        #else
            printGroup(val.groups, level + 1, isPrintChildren)
        #end
    end
    
    return nil
end

# Check if parameters supplied correctly and enough
if ARGV.length < 1
    puts "Usage: zhmanage <command>"
    exit
end

# if all else is okay
# Get command from executing command line
command = ARGV[0]

xcode_project_path = '/Users/haxpor/Data/Projects/ZombieHero/zombie-hero/'
xcode_project_name = 'ZombieHero.xcodeproj'

project_file = "#{xcode_project_path}#{xcode_project_name}"

puts "Processing #{project_file} ..."

project = Xcodeproj::Project.open(project_file)

#
# zhmange listgroup
# List all group under the project.
#
if command == "listgroup"
    printGroup(project.groups, 0, false)

#
# zhmanage addfile <file-path> <group-path>
# Command to add a file from 'file-path' under the 'group-path'
# Note: It's better and risk-free to go to the file folder then execute the command with 'file-path' as only a filename.
#
elsif command == "addfile"
    # check if parameter is not enough
    if ARGV.length < 2
        puts "Usage: zhmanage addfile <file-path> <group-path>"
        exit
    end

    # If okay, then gather each parameter
    filePath = ARGV[1]
    groupPath = ARGV[2]

    # get the group of the path to add a new file
    group = project[groupPath]
    fileRef = group.new_reference(filePath)

    if !fileRef.nil?
        puts "Adding '#{fileRef.display_name}' ..."
        puts " .Added under the group '#{group.display_name}' successfully."

        # iterate through all the native-targets in order to build source file (no header file in this project)
        project.native_targets.each do |native_target|
            
            # adding as part of the target build phase only
            # if it's header file, we ignore it
            extension = File.extname(fileRef.display_name).downcase
            header_extensions = Xcodeproj::Constants::HEADER_FILES_EXTENSIONS
            if !header_extensions.include?(extension)
                puts "\tAdding as part of source-build-phase for '#{native_target.display_name}'" 

                # get source build phase
                source_build_phase = native_target.source_build_phase
                # add file into source build phase
                buildFile = source_build_phase.add_file_reference(fileRef, true)

                if !buildFile.nil?
                    # we're done
                    puts "\t .Added as part of source-build-phase successfully."
                else
                    # we failed
                    # thus we don't save project
                    puts "\t .Failed to add as part of source-build-phase"

                    # exit immediately
                    exit
                end
            end
        end

        # all is okay, we are about to save
        # save the project
        project.save
    else
        # we failed
        # thus we don't save the project
        puts "Failed to add '#{filePath}"

        # exit immediately
        exit
    end
else
    puts "#{command} command not recognized."
end
