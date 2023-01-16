def sprite_create_base(path, atlas_w, atlas_h, columns, rows)
  {
    path: path,
    rows: rows,
    columns: columns,
    animations: {},
    source_w: atlas_w.div(columns),
    source_h: atlas_h.div(rows),
    source_x: 0,
    source_y: 0,
    frame: 0,
    last_animation: "",
    frame_counter: 0
  }
end

def sprite_add_animation(sprite, name, column, row, length, ticks_per_frame)
  data = []

  i = 0
  while i < length
    data << {
      x: column * sprite.source_w + sprite.source_w * i,
      y: row * sprite.source_h
    }
    i += 1
  end

  sprite.animations[name] = {
    ticks_per_frame: ticks_per_frame,
    animation_length: length,
    data: data
  }

end

def sprite_set_animation(sprite, name)
  return if sprite.last_animation == name
  sprite.last_animation = name
  sprite.frame = 0
  sprite.frame_counter = 0
end

def sprite_update_animation(sprite)
  s = sprite.animations[sprite.last_animation]
  data = s.data
  if sprite.frame_counter > s.ticks_per_frame
    sprite.frame += 1
    sprite.frame_counter = 0
  end

  frame = data[sprite.frame % s.animation_length]
  sprite.source_x = frame.x
  sprite.source_y = frame.y

  sprite.frame_counter += 1
end