extends Node
## Signals between gameplay and UI. Gameplay emits what happened; UI listens and updates.
## Neither side holds a reference to the other.

# Run
signal win
signal lose
signal endless_started
signal expert_updated
signal bucks_updated(value: int)
signal health_updated(value: int)
signal tutorial_requested

# Waves
signal next_wave_requested
signal wave_started(number: int)
## A wave was beaten and the next one can be started (not sent after the last wave).
signal wave_cleared

# Towers and placement
signal shop_item_clicked(item: ShopItem)
signal shop_item_hovered(item: ShopItem)
signal shop_item_unhovered
signal shop_opened(open: bool)
signal placing_started(tower: Tower)
signal placing_stopped
signal tower_damage_dealt(tower: Tower, amount: int)
signal error
