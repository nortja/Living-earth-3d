extends RefCounted

# Offline editorial catalog. Coordinates identify the place, not a camera feed.
const PLACES := [
    {"name": "Grand Canyon", "region": "Arizona, United States", "latitude": 36.1, "longitude": -112.1,
    "fact": "The Colorado River carved this canyon through layers of rock that record nearly two billion years of Earth's history."},
    {"name": "Great Barrier Reef", "region": "Queensland, Australia", "latitude": -18.3, "longitude": 147.7,
    "fact": "This reef system stretches for more than 2,300 kilometers along Australia's northeast coast."},
    {"name": "Mount Everest", "region": "Himalayas, Nepal / China", "latitude": 27.99, "longitude": 86.93,
    "fact": "Earth's highest mountain above sea level rises where the Indian and Eurasian tectonic plates meet."},
    {"name": "Sahara", "region": "North Africa", "latitude": 23.4, "longitude": 13.0,
    "fact": "The world's largest hot desert includes rocky plateaus, mountains, and vast sand seas."},
    {"name": "Amazon Basin", "region": "South America", "latitude": -3.1, "longitude": -60.0,
    "fact": "The Amazon carries more water to the ocean than any other river."},
    {"name": "Iceland", "region": "North Atlantic", "latitude": 64.96, "longitude": -19.02,
    "fact": "Iceland straddles the Mid-Atlantic Ridge, where two tectonic plates slowly pull apart."}
]
