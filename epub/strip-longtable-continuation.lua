-- Pandoc reads LaTeX longtable's \endhead/\endfoot blocks as literal body
-- rows, producing "Table continued from previous page", a duplicated header
-- row, and "Continued on next page" in EPUB/HTML output. Those are PDF
-- pagination artifacts with no meaning in a reflowable document, so drop them.

local stringify = pandoc.utils.stringify

local function row_signature(row)
  local parts = {}
  for _, cell in ipairs(row.cells) do
    parts[#parts + 1] = stringify(cell.contents)
  end
  return table.concat(parts, "\31"):lower():gsub("%s+", " "):gsub("^ ", ""):gsub(" $", "")
end

local function filter_rows(rows, header_sigs)
  local kept = {}
  for _, row in ipairs(rows) do
    local sig = row_signature(row)
    local is_continuation =
      sig:find("continued on next page", 1, true)
      or sig:find("table continued from previous page", 1, true)
      or header_sigs[sig]
    if not is_continuation then
      kept[#kept + 1] = row
    end
  end
  return kept
end

function Table(tbl)
  local header_sigs = {}
  for _, row in ipairs(tbl.head.rows) do
    header_sigs[row_signature(row)] = true
  end
  for _, body in ipairs(tbl.bodies) do
    body.head = filter_rows(body.head, header_sigs)
    body.body = filter_rows(body.body, header_sigs)
  end
  return tbl
end
