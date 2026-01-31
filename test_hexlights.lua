local hexlights = require("hexlights")

describe(
    "tests of clamp utility function",
    function()
        it("clamps number below range", function()
            assert.are.equal(hexlights.clamp(-1, 1, 5), 1)
        end)

        it("clamps number below range", function()
            assert.are.equal(hexlights.clamp(10, 1, 5), 5)
        end)

        it("clamps number within range", function()
            assert.are.equal(hexlights.clamp(3, 1, 5), 3)
        end)
    end)
