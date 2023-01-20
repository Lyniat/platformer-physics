def fix_rel_path(path)
  path_parts = path.split("/")
  new_parts = []
  path_parts.each do |part|
    if part == ".." and !new_parts.empty?
      new_parts.pop
    else
      new_parts << part
    end
  end
  path = ""
  new_parts.each do |part|
    path += "/#{part}"
  end
  path
end

def hex_to_rgba(hex_color)
  r = hex_color[1..2].to_i(16)
  g = hex_color[3..4].to_i(16)
  b = hex_color[5..6].to_i(16)
  a = 255
  if hex_color.size > 7
    a = hex_color[7..8].to_i(16)
  end
  {r: r, g: g, b: b, a: a}
end