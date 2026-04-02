function Image(elem)
  elem.src = elem.src:gsub("%.pdf$", ".svg")
  return elem
end