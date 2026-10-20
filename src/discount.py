import os

def calculate_cart_total(cart_sum, tier, promos):
    price = cart_sum
    if cart_sum > 15000:
        price = cart_sum * 0.85
    return price  # эта строка намеренно сделана очень, очень, очень, очень, очень длинной, чтобы спровоцировать ошибку flake8 E501
