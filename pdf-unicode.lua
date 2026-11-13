-- PDF only: the Tectonic default fonts lack Greek letters, math symbols and
-- box-drawing characters. Map them to LaTeX math in text and to ASCII in code.
local math_map = {
  ["π"] = "\\pi", ["β"] = "\\beta", ["α"] = "\\alpha",
  ["≤"] = "\\leq", ["≥"] = "\\geq", ["≈"] = "\\approx",
}
local ascii_map = {
  ["π"] = "pi", ["β"] = "beta", ["α"] = "alpha",
  ["≤"] = "<=", ["≥"] = ">=", ["≈"] = "~",
  ["─"] = "-", ["│"] = "|", ["┌"] = "+", ["┐"] = "+", ["└"] = "+",
  ["┘"] = "+", ["├"] = "+", ["┤"] = "+", ["┬"] = "+", ["┴"] = "+", ["┼"] = "+",
}

local function to_ascii(s)
  for k, v in pairs(ascii_map) do s = s:gsub(k, v) end
  return s
end

function CodeBlock(el) el.text = to_ascii(el.text); return el end
-- Inline code: emit \texttt with break opportunities after _ , ( ) / . so long
-- identifiers wrap instead of overflowing the line.
local latex_escape = {
  ["\\"] = "\\textbackslash{}", ["{"] = "\\{", ["}"] = "\\}", ["#"] = "\\#",
  ["$"] = "\\$", ["%"] = "\\%", ["&"] = "\\&", ["_"] = "\\_\\allowbreak{}",
  ["^"] = "\\^{}", ["~"] = "\\textasciitilde{}", ["<"] = "\\allowbreak{}\\textless{}",
  [">"] = "\\textgreater{}\\allowbreak{}", ["|"] = "\\textbar{}", ['"'] = "\\textquotedbl{}",
  ["'"] = "\\textquotesingle{}", ["`"] = "\\textasciigrave{}",
  [","] = ",\\allowbreak{}", ["("] = "(\\allowbreak{}", ["/"] = "/\\allowbreak{}",
  ["."] = ".\\allowbreak{}", ["-"] = "-\\allowbreak{}", ["="] = "=\\allowbreak{}",
}
function Code(el)
  local t = to_ascii(el.text):gsub("[\\{}#$%%&_%^~<>|\"'`,(/.%-=]", function(c)
    return latex_escape[c]
  end)
  -- also allow a break at camelCase boundaries (decodeToRenameDelay)
  t = t:gsub("(%l)(%u)", "%1\\allowbreak{}%2")
  return pandoc.RawInline("latex", "\\texttt{" .. t .. "}")
end

local function breakable_word(txt)
  local t = txt:gsub("[\\{}#$%%&_%^~]", function(c)
    return ({["\\"]="\\textbackslash{}",["{"]="\\{",["}"]="\\}",["#"]="\\#",["$"]="\\$",
             ["%"]="\\%",["&"]="\\&",["_"]="\\_",["^"]="\\^{}",["~"]="\\textasciitilde{}"})[c]
  end)
  t = t:gsub("(%l)(%u)", "%1\\allowbreak{}%2"):gsub("(%u)(%d)", "%1\\allowbreak{}%2")
  return pandoc.RawInline("latex", t)
end

function Str(el)
  if #el.text >= 18 and not el.text:find("[\128-\255]") and el.text:find("%u") then
    return breakable_word(el.text)
  end
  local out, changed = {}, false
  for ch in el.text:gmatch("[%z\1-\127\194-\244][\128-\191]*") do
    if math_map[ch] then
      out[#out + 1] = pandoc.Math("InlineMath", math_map[ch]); changed = true
    else
      out[#out + 1] = pandoc.Str(ch)
    end
  end
  if changed then return out end
end

-- Tables: pipe tables take column widths from the dash counts in the separator
-- row, which often squeezes short columns ("Conditional") below their longest
-- word. Re-derive widths from the cell content instead.
local function cell_text(cell) return pandoc.utils.stringify(cell.contents) end

function Table(tbl)
  local ncol = #tbl.colspecs
  local longest_word, longest_cell = {}, {}
  for i = 1, ncol do longest_word[i] = 4; longest_cell[i] = 4 end
  local function scan(row)
    for i, cell in ipairs(row.cells) do
      local txt = cell_text(cell)
      if #txt > longest_cell[i] then longest_cell[i] = #txt end
      for w in txt:gmatch("%S+") do
        if #w > longest_word[i] then longest_word[i] = #w end
      end
    end
  end
  for _, r in ipairs(tbl.head.rows) do scan(r) end
  for _, body in ipairs(tbl.bodies) do
    for _, r in ipairs(body.body) do scan(r) end
  end
  local weights, total = {}, 0
  for i = 1, ncol do
    -- at least the longest word (capped), plus a share of the longest cell
    weights[i] = math.max(math.min(longest_word[i], 22) * 1.35 + 3, math.min(longest_cell[i], 60) * 0.45)
    total = total + weights[i]
  end
  for i = 1, ncol do tbl.colspecs[i][2] = weights[i] / total end
  return tbl
end
