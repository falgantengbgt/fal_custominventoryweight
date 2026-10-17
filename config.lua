Config = {}

-- Pilihan framework: 'qbx' | 'qb' | 'esx' | 'auto'
-- Kalo 'auto', dia otomatis ngebaca framework apa aja yang lu pake
Config.Framework = 'auto'

-- Log discord webhook untuk /setweight saat admin ngasih weight ke siapa aja akan masuk ke log discord
Config.Discord = {
    enabled = true,
    webhook = 'https://discordapp.com/api/webhooks/1558192833993904280/Vq1AQOgEYWE7953yKBZmpc8f8LDalCi_FpoyZNSjNnIvAnFmmnfDPwWcD9WWGIfFHuGB',
    botName = 'Log Set Weight',
    botAvatar = '', -- Tempel link gambar bot kalo mau
}

-- Berat bawaan kalo ID-nya ga terdaftar (false = ikut default ox_inventory)
Config.DefaultWeight = false 

-- Daftar berat tas (Hitungan Gram: 1 KG = 1000 Gram)
-- Bebas isi angka berapa aja, ga ada batas minimal / maksimal
Config.Weights = {
    ['CJK39102']               = 50000,  -- 50 KG / citizen id
    ['steam:11000011338f49a']  = 165000, -- 165 KG / steamhex
    ['110000137031818']        = 900000, -- 900 KG / steamhex juga
    ['license:abcdef12345678'] = 80000,  -- 80 KG / license
}