%lang starknet
from starkware.cairo.common.math_cmp import is_le

# TODO
# Rewrite those functions with a high level syntax
@external
func sum_array(array_len : felt, array : felt*) -> (sum : felt):
    # [ap] = [fp - 4]; ap++
    # [ap] = [fp - 3]; ap++
    # [ap] = 0; ap++
    # ret
    let (sum) = rec_sum_array(array_len, array, 0)
    return (sum)
end

func rec_sum_array(array_len : felt, array : felt*, sum : felt) -> (sum : felt):
    # jmp continue if [fp - 5] != 0

    # stop:
    # [ap] = [fp - 3]; ap++
    # jmp done

    # continue:
    # [ap] = [[fp - 4]]; ap++
    # [ap] = [fp - 5] - 1; ap++
    # [ap] = [fp - 4] + 1; ap++
    # [ap] = [ap - 3] + [fp - 3]; ap++
    # call rec_sum_array

    # done:
    # ret
    if array_len == 0:
        return (sum)
    end
    let new_sum = sum + array[0]
    let (sum) = rec_sum_array(array_len - 1, array + 1, new_sum)
    return (sum)
end

# TODO
# Rewrite this function with a low level syntax
# It's possible to do it with only registers, labels and conditional jump. No reference or localvar
@external
func max{range_check_ptr}(a : felt, b : felt) -> (max : felt):
    let (res) = is_le(a, b)
    if res == 1:
        return (b)
    else:
        return (a)
    end
    # [ap] = [fp - 5]; ap++
    # [ap] = [fp - 4]; ap++
    # call is_le
    # jmp labelb if [ap] != 0
    # [ap] = [fp - 5]; ap++
    # jmp done

    # labelb:
    # [ap] = [fp - 4]; ap++

    # done:
    # [ap] = [fp - 6]; ap++
    # %{ memory[ap] = 42 %}
    # [ap] = [ap]; ap++
    # # [ap] = (42); ap++
    # ret
end

#########
# TESTS #
#########

from starkware.cairo.common.alloc import alloc

@external
func test_max{range_check_ptr}():
    let (m) = max(21, 42)
    assert m = 42
    let (m) = max(42, 21)
    assert m = 42
    return ()
end

@external
func test_sum():
    let (array) = alloc()
    assert array[0] = 1
    assert array[1] = 2
    assert array[2] = 3
    assert array[3] = 4
    assert array[4] = 5
    assert array[5] = 6
    assert array[6] = 7
    assert array[7] = 8
    assert array[8] = 9
    assert array[9] = 10

    let (s) = sum_array(10, array)
    assert s = 55

    return ()
end
