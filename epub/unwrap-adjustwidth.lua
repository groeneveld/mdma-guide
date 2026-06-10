-- Clean up the LaTeX `adjustwidth` environment (from the changepage/memoir
-- package) for HTML and EPUB output. Pandoc doesn't recognise the environment,
-- so it parses the two length arguments (e.g. {1.5em}{}) as leading body
-- content: an empty-attribute Span holding the dimension, which would otherwise
-- render as a stray "1.5em" before the text. We drop those leading argument
-- Spans (and the whitespace after them) and keep the `.adjustwidth` div class so
-- the left indent can be restored with CSS.

local stringify = pandoc.utils.stringify

-- A TeX length argument is either empty or a number with an optional unit
-- (em, pt, cm, ...). We only strip Spans whose text matches that shape, so
-- genuine empty-attribute spans in the body are left untouched.
local function looks_like_length(inlines)
  local s = stringify(inlines)
  return s == "" or s:match("^%s*%-?%d*%.?%d+%s*%a*%s*$") ~= nil
end

local function strip_leading_args(inlines)
  while #inlines > 0 do
    local first = inlines[1]
    if first.t == "Span"
        and first.identifier == ""
        and #first.classes == 0
        and looks_like_length(first.content) then
      table.remove(inlines, 1)
      while #inlines > 0
          and (inlines[1].t == "Space"
            or inlines[1].t == "SoftBreak"
            or inlines[1].t == "LineBreak") do
        table.remove(inlines, 1)
      end
    else
      break
    end
  end
  return inlines
end

function Div(el)
  if el.classes:includes("adjustwidth") then
    if #el.content > 0 and el.content[1].t == "Para" then
      el.content[1].content = strip_leading_args(el.content[1].content)
    end
    return el
  end
end
