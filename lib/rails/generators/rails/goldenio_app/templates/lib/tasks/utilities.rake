def print_info title
  puts "---- #{title} ----"
  yield
  puts "--------"
end

def import_yaml_file file_path
  imported = []
  import = YAML.load File.read(file_path)
  import.each do |attrs|
    yield attrs, imported
  end
  puts "---- File #{file_path} imported ----"
  imported.each { |subject| puts subject }
  puts "---- Total imported: #{imported.size}/#{import.size} ----"
end

def import_json_file file_path
  imported = []
  import = JSON.parse File.read(file_path)
  import.each do |attrs|
    yield attrs, imported
  end
  puts "---- File #{file_path} imported ----"
  imported.each { |subject| puts subject }
  puts "---- Total imported: #{imported.size}/#{import.size} ----"
end

def import_csv_file file_path, csv_options
  imported_size = 0
  line_number = 0
  puts "---- File #{file_path} importing ----"
  CSV.foreach(file_path, csv_options) do |row|
    imported = []
    yield row, line_number, imported
    puts imported
    imported_size += 1
    line_number += 1
  end
  puts "---- Total imported: #{imported_size}/#{line_number} ----"
end
