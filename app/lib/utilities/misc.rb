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