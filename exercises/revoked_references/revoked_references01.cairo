%lang starknet

# References in Cairo are like aliases to specific memory cells pointed by ap

# I AM NOT DONE

# TODO: complete the congratulate function with some if statements
# You will encounter a "revoked reference" error
# https://www.cairo-lang.org/docs/how_cairo_works/consts.html#revoked-references

from starkware.cairo.common.cairo_builtins import HashBuiltin

@storage_var
func congratulation() -> (value : felt):
end

func congratulate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    score : felt
) -> ():
    return ()
end

# Do not change the test
@external
func test_congratulate{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let score = 0
    congratulate(score)
    let (current_congratulation) = congratulation.read()
    assert current_congratulation = 'You can do better'

    let score = 10
    congratulate(score)
    let (current_congratulation) = congratulation.read()
    assert current_congratulation = 'You did good'

    return ()
end
