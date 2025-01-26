
return_values = [
    ['Here are 20 recent or trending songs across the requested BPM ranges, all in the key of C Major:'],
    ["Dua Lipa", "Don't Start Now", "80-120 BPM"],
    ["Ariana Grande", "7 Rings", "120-160 BPM"],
    ["Ed Sheeran", "Shape of You", "100-120 BPM"],
    ["Billie Eilish", "Bad Guy", "110-130 BPM"],
    ["Lizzo", "Good as Hell", "120-140 BPM"],
    ["Vance Joy", "Riptide", "40-60 BPM"],
    ["Lewis Capaldi", "Someone You Loved", "60-80 BPM"],
    ["Lana Del Rey", "Summertime Sadness", "50-70 BPM"],
    ["Maggie Rogers", "Light On", "60-80 BPM"],
    ["Shawn Mendes", "In My Blood", "70-90 BPM"],
    ["The Weeknd", "Blinding Lights", "170-190 BPM"],
    ["Cardi B", "WAP", "160-180 BPM"],
    ["Megan Thee Stallion", "Savage", "155-175 BPM"],
    ["BLACKPINK", "How You Like That", "170-190 BPM"],
    ["BTS", "Dynamite", "175-195 BPM"]
]


def processValues(return_values):
    songs_list = []
    for value in return_values:
        if (len(value) < 3):
            continue
        # print(value)
        lower, chunk1 = value[2].split('-')
        higher, useless = chunk1.split(' ')
        lower = int(lower)
        higher = int(higher)
        avg_bpm = (lower + higher)//2

        songs_list.append([avg_bpm, value[1], value[0]])
    return sorted(songs_list, key=lambda x: x[0])

def getClosestBPM(target_bpm):
    closest_song = min(songs_list, key=lambda x: abs(x[0] - target_bpm))
    return closest_song

songs_list = processValues(return_values)

print(getClosestBPM(115))