# frozen_string_literal: true

require 'json'

# Saves and loads the game.
module FileManager
  extend self

  def save_file(save_data)
    files = save_file_list
    puts "\nExisting save files are listed below:\n"
    display_save_files(files)

    puts "\nName your save file - 'cancel' to cancel\n"
    file_name = ask_file_name

    return false if file_name == ''

    File.open("saves/#{file_name}.txt", 'w') do |file|
      file.puts save_data.to_json
    end

    File.exist? "saves/#{file_name}.txt"
  end

  def load_file
    files = save_file_list
    puts <<~HEREDOC

      Type the name of a save file listed below to load it,
      or press Enter to start a new game:

    HEREDOC
    display_save_files(files)
    file_name = ask_file_name
    return nil if file_name == 'cancel' || !files.include?(file_name)

    file = File.open("saves/#{file_name}.txt", 'r')
    data = JSON.load file.gets
    data.transform_keys!(&:to_sym)
  end

  private

  def save_file_list
    if Dir.exist?('saves/.')
      Dir.entries('saves/.').filter { |file| !file.start_with?('.') }.map { |file_name| file_name[0..-5] }
    else
      ['-- no save files in directory --']
    end
  end

  def display_save_files(files)
    files.each do |file_name|
      next if file_name[0] == '.'

      puts "- #{file_name}"
    end
  end

  def ask_file_name
    print '>> '
    gets.chomp.strip
  end
end
