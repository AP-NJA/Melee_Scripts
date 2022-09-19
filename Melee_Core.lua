local core = {}

local function getPos()
    return {
        X = ReadValueFloat(0x453130, 0x2C, 0xB0),
        Y = ReadValueFloat(0x453130, 0x2C, 0xB4)
    }
end
core.getPos = getPos

local function getSpeed()
    local address = ReadValueFloat(0x453130, 0x2C, 0x80)
    local TotalSpeed = math.abs(address)
    return address, TotalSpeed
end
core.getSpeed = getSpeed

local function getRNG()
    return ReadValue32(0x4D5F90)
end
core.getRNG = getRNG

local function inverseRNG(seed) -- created by Trivial171
    local powers = {1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048, 4096, 8192, 16384, 32768, 65536, 131072, 262144, 524288, 1048576, 2097152, 4194304, 8388608, 16777216, 33554432, 67108864, 134217728, 268435456, 536870912, 1073741824, 2147483648}
    local modulo = 0x100000000
    local multi = 0x343FD
    local addi = 0x269EC3

    local function modular_expo(m, n, q)
        if (n == 0) then
            return 1
        else
            local factor1 = modular_expo(m, math.floor(n / 2), q)
            local factor2 = 1

            if (n % 2 == 1) then
                factor2 = m
            end

            return (factor1 * factor1 * factor2) % q
        end
    end

    local function modular_inv(w)
        return modular_expo(w, math.floor(modulo / 2) - 1, modulo)
    end

    local function v2(a)
        if (a == 0) then
            return 1000000
        end

        local n = a
        local v = 0

        while (n % 2 == 0) do
            n = math.floor(n/2)
            v = v + 1
        end

        return v
    end

    local function rnginverse(r)
        local xpow = (r * 4 * math.floor((multi - 1) / 4) * modular_inv(addi) + 1) % (4 * modulo)
        local xguess = 0

        for index, value in ipairs(powers) do
            if v2(modular_expo(multi, xguess + value, 4 * modulo) - xpow) > v2(modular_expo(multi, xguess, 4 * modulo) - xpow) then
               xguess = xguess + value
            end
        end

        return xguess
    end

    return rnginverse(seed)
end
core.inverseRNG = inverseRNG

local function frameOfInput()
    return ReadValue32(0x479D60)
end
core.frameOfInput = frameOfInput

local function getInput()
    local buttons = ReadValue16(0x4C1FAE)
    local stickInput = {
        X = ReadValueFloat(0x4C1FCC),
        Y = ReadValueFloat(0x4C1FD0)
    }
    local str = " "

    local function isPressed(value)
        return buttons & value == value
    end

    local function add(text)
        if str:len() ~= 1 then
            str = str .. " "
        end
        str = str .. text
    end

    if isPressed(0x0001) then add("D-Left") end
    if isPressed(0x0002) then add("D-Right") end
    if isPressed(0x0004) then add("D-Down") end
    if isPressed(0x0008) then add("D-Up") end
    if isPressed(0x0010) then add("Z") end
    if isPressed(0x0020) then add("R") end
    if isPressed(0x0040) then add("L") end
    if isPressed(0x0100) then add("A") end
    if isPressed(0x0200) then add("B") end
    if isPressed(0x0400) then add("X") end
    if isPressed(0x0800) then add("Y") end
    if isPressed(0x1000) then add("Start") end
    return {
        buttonText = str,
        X = stickInput.X,
        Y = stickInput.Y
    }
end
core.getInput = getInput

return core
