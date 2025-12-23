-- Lua filter to replace chemfig commands with pre-rendered SVG images
-- This filter detects \chemfig{...} commands and replaces them with \includegraphics

-- Map chemfig structures to their corresponding SVG files
local chemfig_map = {
  -- MDMA structure
  ["{%*6%(%-%=%-%(%-%-%[%:%:%-60%]%(%-NH%-%[%:%:%-60%]%)%-%[%:%:%-60%]%)%-%=%-%(%*5%(%-%O%-%-%O%-%)%)%=%)}"] = "auxillaryFiles/mdma.svg",
  -- Safrole structure
  ["{%*6%(%-%=%-%(%-%-%[%:%:%-60%]%=%[%:%:60%]%)%-%=%-%(%*5%(%-%O%-%-%O%-%)%)%=%)}"] = "auxillaryFiles/safrole.svg",
  -- Piperonal structure (note: file is named piperonol.svg)
  ["{%*6%(%-%=%-%(%-=%[%:%:%-60%]O%)%-%=%-%(%*5%(%-%O%-%-%O%-%)%)%=%)}"] = "auxillaryFiles/piperonol.svg",
}

-- Function to escape special characters for pattern matching
local function escape_pattern(str)
  return str:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1")
end

-- Build reverse lookup table with escaped patterns
local pattern_to_svg = {}
for pattern, svg in pairs(chemfig_map) do
  -- Unescape the pattern for actual matching
  local unescaped = pattern:gsub("%%", "")
  pattern_to_svg[unescaped] = svg
end

function RawBlock(elem)
  if elem.format == "latex" or elem.format == "tex" then
    local text = elem.text

    -- Check if this block contains a chemfig command
    if text:match("\\chemfig") then
      -- Try to extract the chemfig argument
      local chemfig_arg = text:match("\\chemfig(%b{})")

      if chemfig_arg then
        -- Look up the corresponding SVG file
        local svg_file = pattern_to_svg[chemfig_arg]

        if svg_file then
          -- Replace the chemfig command with includegraphics
          local new_text = text:gsub(
            "\\chemfig" .. escape_pattern(chemfig_arg),
            "\\includegraphics[width=0.3\\textwidth]{" .. svg_file .. "}"
          )

          return pandoc.RawBlock("latex", new_text)
        end
      end
    end
  end

  return elem
end

function RawInline(elem)
  if elem.format == "latex" or elem.format == "tex" then
    local text = elem.text

    -- Check if this inline element contains a chemfig command
    if text:match("\\chemfig") then
      -- Try to extract the chemfig argument
      local chemfig_arg = text:match("\\chemfig(%b{})")

      if chemfig_arg then
        -- Look up the corresponding SVG file
        local svg_file = pattern_to_svg[chemfig_arg]

        if svg_file then
          -- Replace the chemfig command with includegraphics
          local new_text = text:gsub(
            "\\chemfig" .. escape_pattern(chemfig_arg),
            "\\includegraphics[width=0.3\\textwidth]{" .. svg_file .. "}"
          )

          return pandoc.RawInline("latex", new_text)
        end
      end
    end
  end

  return elem
end
