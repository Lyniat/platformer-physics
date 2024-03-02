def map_get_int_layer(args, file)
  content = args.gtk.read_file(file)
  columns = content.count("\n")
  content = content.delete("\n")
  int_data = content.split(",")
  int_data.map!(&:to_i)
  rows = int_data.length / columns
  [int_data, columns, rows]
end

def string_to_rgb(hex_string)
  hex_string = hex_string.delete("#")
  r = hex_string[0..1].to_i(16)
  g = hex_string[2..3].to_i(16)
  b = hex_string[4..5].to_i(16)
  {
    r: r,
    g: g,
    b: b,
    a: 255}
end
