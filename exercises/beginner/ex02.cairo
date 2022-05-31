%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.starknet.common.syscalls import get_caller_address
from starkware.cairo.common.math import assert_le

# We want to store more info than just the `star` size.
# We are going to give them a name and a size

# TODO
# Create a `Star` stuct
# It must have two members:
# - name
# - size
# Both members are of type `felt`
# https://www.cairo-lang.org/docs/reference/syntax.html#structs
struct Star:
   member name: felt
   member size: felt
end

@storage_var
func dust(address : felt) -> (amount : felt):
end

# TODO
# Update the `star` storage to store `Star` instead of `felt`
@storage_var
func star(address : felt, slot: felt) -> (star: Star):
end

@storage_var
func slot(address : felt) -> (slot : felt):
end

@event
func a_star_is_born(account : felt, slot : felt, size : Star):
end

@external
func collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(amount : felt):
    let (address) = get_caller_address()

    let (res) = dust.read(address)
    dust.write(address, res + amount)

    return ()
end

# TODO
# Update the `light_star` external so it take a `Star` struct instead of the amount of dust
# Caller `dust` storage must be deducted from an amount equal to the star size
@external
func light_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    newStar: Star
):
    # TODO
    # Get the caller address
    let (sender_address) = get_caller_address()
    # Get the amount on dust owned by the caller
    let (current_dust) = dust.read(sender_address)
    # Make sure this amount is at least equal to `dust_amount`
    assert_le(newStar.size, current_dust)
    # Get the caller next available `slot`
    let (next) = slot.read(sender_address)
    # Update the amount of dust owned by the caller
    let newdust = current_dust - newStar.size
    dust.write(sender_address, newdust)
    # Register the newly created star, with a size equal to `dust_amount`
    star.write(sender_address, next, newStar)
    # Increment the caller next available slot
    slot.write(sender_address, next+1)
    # Emit an `a_star_is_born` even with appropiate valued
    a_star_is_born.emit(sender_address, next, newStar)
    return ()
end

@view
func view_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (amount : felt):
    let (res) = dust.read(address)
    return (res)
end

@view
func view_slot{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    address : felt
) -> (amount : felt):
    let (res) = slot.read(address)
    return (res)
end

# TODO
# Create a view for `star`
# It must return an instance of `Star` instead of a `felt`
@view
func view_star{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(address : felt, slot: felt) -> (star: Star):
    let (mystar) = star.read(address, slot)
    return (mystar)
end

#########
# TESTS #
#########

@external
func test_collect_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    collect_dust(5)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 5

    collect_dust(10)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 15

    return ()
end

@external
func test_light_star_ok{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    collect_dust(100)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 100

    # `Andromeda` encoded
    light_star(Star(0x416e64726f6d656461, 60))
    let (dust_amount) = view_dust(0)
    assert dust_amount = 40
    let (slot) = view_slot(0)
    assert slot = 1
    let (star) = view_star(0, 0)
    assert star.name = 0x416e64726f6d656461
    assert star.size = 60

    return ()
end

@external
func test_light_star_ko{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    collect_dust(100)
    let (dust_amount) = view_dust(0)
    assert dust_amount = 100

    %{ expect_revert() %}
    light_star(Star(0x416e64726f6d656461, 1000))
    let (dust_amount) = view_dust(0)
    assert dust_amount = 100
    let (slot) = view_slot(0)
    assert slot = 0

    return ()
end
