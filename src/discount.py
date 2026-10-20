def calculate_cart_total(cart_sum, tier, promos):
    price = cart_sum
    if cart_sum > 15000:
        price = cart_sum * 0.85
    return price
