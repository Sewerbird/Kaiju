function max(a,b)
  return math.max(a,b)
end

function min(a,b)
  return math.min(a,b)
end

function mod(a,b)
  local q = math.floor(a/b)
  return a - (q*b)
end

function abs(a)
  return math.sqrt(a*a)
end

function clamp(a,low,high)
  if a < low then
    return low
  elseif a > high then
    return high
  else
    return a
  end
end

function wrap(a,low,high)
  if a < low then
    return high
  elseif a > high then
    return low
  else
    return a
  end
end

function lerp(start, finish, t)
  return (t * (finish - start)) + start
end

function rand(min,max)
  return love.math.random() * (max - min) + min
end

function read_lua_from_json(filename)
  local contents, size = love.filesystem.read(filename)
  --TODO Use a proper parser for this
  local L="return "..(contents:gsub('("[^"]-"):','[%1]='))
  local T=loadstring(L)()
  return T
end
