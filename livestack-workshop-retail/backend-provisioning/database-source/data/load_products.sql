/*
 * load_products.sql
 * 250 products across 50 brands — diverse categories
 * Uses PL/SQL to generate volume with variety
 */

SET SERVEROUTPUT ON
PROMPT Loading products...

DECLARE
    TYPE t_prod IS RECORD (
        bslug VARCHAR2(100),
        pname VARCHAR2(300),
        cat   VARCHAR2(100),
        subcat VARCHAR2(100),
        price NUMBER(10,2),
        cost  NUMBER(10,2),
        wt    NUMBER(8,3),
        tags  VARCHAR2(1000)
    );
    TYPE t_prod_arr IS TABLE OF t_prod;
    v_prods t_prod_arr := t_prod_arr();
    v_brand_id NUMBER;
    v_sku VARCHAR2(50);
    v_idx NUMBER := 0;

    PROCEDURE add_prod(p_slug VARCHAR2, p_name VARCHAR2, p_cat VARCHAR2, p_sub VARCHAR2,
                       p_price NUMBER, p_cost NUMBER, p_wt NUMBER, p_tags VARCHAR2) IS
        v_rec t_prod;
    BEGIN
        v_rec.bslug := p_slug; v_rec.pname := p_name; v_rec.cat := p_cat;
        v_rec.subcat := p_sub; v_rec.price := p_price; v_rec.cost := p_cost;
        v_rec.wt := p_wt; v_rec.tags := p_tags;
        v_prods.EXTEND; v_prods(v_prods.COUNT) := v_rec;
    END;
BEGIN
    -- UrbanPulse (Fashion)
    add_prod('urbanpulse','Midnight Bomber Jacket','Fashion','Outerwear',189.99,72,1.2,'jacket,bomber,streetwear,trending');
    add_prod('urbanpulse','Neon Grid Hoodie','Fashion','Tops',89.99,32,0.6,'hoodie,neon,streetwear,viral');
    add_prod('urbanpulse','Carbon Slim Joggers','Fashion','Bottoms',74.99,28,0.4,'joggers,slim,carbon,athleisure');
    add_prod('urbanpulse','Retro Wave Tee','Fashion','Tops',39.99,12,0.2,'tshirt,retro,wave,casual');
    add_prod('urbanpulse','Urban Camo Backpack','Fashion','Accessories',129.99,48,0.8,'backpack,camo,urban,travel');

    -- TechNova (Electronics)
    add_prod('technova','NovaPad Pro 15','Electronics','Tablets',899.99,420,0.68,'tablet,pro,stylus,creative');
    add_prod('technova','AirBud Elite TWS','Electronics','Audio',199.99,65,0.05,'earbuds,wireless,anc,premium');
    add_prod('technova','SmartDock 4K Hub','Electronics','Accessories',149.99,52,0.35,'dock,usbc,4k,hub');
    add_prod('technova','NovaWatch Ultra','Electronics','Wearables',449.99,180,0.06,'smartwatch,health,gps,ultra');
    add_prod('technova','PowerStack 20000','Electronics','Chargers',79.99,28,0.45,'powerbank,20000mah,fast-charge');

    -- GlowKin (Beauty)
    add_prod('glowkin','Glass Skin Serum','Beauty','Skincare',68.99,18,0.1,'serum,glass-skin,hyaluronic,viral');
    add_prod('glowkin','Cloud Cream Moisturizer','Beauty','Skincare',54.99,14,0.15,'moisturizer,cloud,lightweight');
    add_prod('glowkin','Sunset Blush Palette','Beauty','Makeup',42.99,11,0.12,'blush,palette,sunset,warm-tones');
    add_prod('glowkin','Dewy Setting Spray','Beauty','Makeup',28.99,7,0.12,'setting-spray,dewy,glow');
    add_prod('glowkin','Vitamin C Brightener','Beauty','Skincare',58.99,15,0.1,'vitamin-c,brightening,serum');

    -- PeakForm (Fitness)
    add_prod('peakform','TitanGrip Dumbbells 50lb','Fitness','Weights',249.99,95,22.7,'dumbbells,adjustable,home-gym');
    add_prod('peakform','FlexBand Pro Set','Fitness','Accessories',49.99,12,0.5,'resistance-bands,set,portable');
    add_prod('peakform','AeroSpin Cycle','Fitness','Cardio',1299.99,520,45,'spin-bike,connected,cardio');
    add_prod('peakform','CoreBlast Ab Roller','Fitness','Accessories',34.99,9,1.2,'ab-roller,core,portable');
    add_prod('peakform','HydroShock Shaker','Fitness','Nutrition',24.99,6,0.3,'shaker,bottle,protein,bpa-free');

    -- NestCraft (Home)
    add_prod('nestcraft','Artisan Pour-Over Set','Home','Kitchen',89.99,32,1.5,'pour-over,coffee,artisan,ceramic');
    add_prod('nestcraft','Woven Throw Blanket','Home','Decor',119.99,42,1.8,'blanket,woven,cozy,hygge');
    add_prod('nestcraft','Smart Herb Garden','Home','Garden',149.99,55,3.2,'herb-garden,smart,indoor,led');
    add_prod('nestcraft','Minimalist Wall Clock','Home','Decor',79.99,28,0.8,'clock,minimalist,wall,modern');
    add_prod('nestcraft','Bamboo Organizer Set','Home','Storage',59.99,18,2.1,'bamboo,organizer,sustainable,desk');

    -- VoltEdge (Electronics)
    add_prod('voltedge','ThunderBolt Charger 140W','Electronics','Chargers',89.99,32,0.3,'charger,140w,gan,usbc');
    add_prod('voltedge','EdgeScreen Monitor 32','Electronics','Displays',549.99,220,8.5,'monitor,32inch,4k,usbc');
    add_prod('voltedge','VoltKey Mechanical KB','Electronics','Peripherals',169.99,58,0.9,'keyboard,mechanical,rgb,wireless');
    add_prod('voltedge','StealthMouse Pro','Electronics','Peripherals',99.99,35,0.08,'mouse,wireless,ergonomic,gaming');
    add_prod('voltedge','SnapCam 4K Webcam','Electronics','Cameras',129.99,42,0.15,'webcam,4k,autofocus,streaming');

    -- SonicWave (Audio)
    add_prod('sonicwave','BassQuake 500 Speaker','Audio','Speakers',299.99,110,4.5,'speaker,bluetooth,bass,portable');
    add_prod('sonicwave','StudioPro Headphones','Audio','Headphones',349.99,120,0.35,'headphones,studio,anc,hires');
    add_prod('sonicwave','PodMic USB Microphone','Audio','Microphones',149.99,52,0.6,'microphone,usb,podcast,streaming');
    add_prod('sonicwave','WaveBar Soundbar','Audio','Soundbars',449.99,175,5.2,'soundbar,dolby,hdmi,arc');
    add_prod('sonicwave','TinyBoom Mini Speaker','Audio','Speakers',59.99,18,0.2,'speaker,mini,waterproof,clip');

    -- TrailBlaze (Outdoor)
    add_prod('trailblaze','Summit 65L Backpack','Outdoor','Backpacks',229.99,85,1.8,'backpack,65L,hiking,waterproof');
    add_prod('trailblaze','AllTerrain Hiking Boots','Outdoor','Footwear',189.99,68,1.6,'boots,hiking,waterproof,gore-tex');
    add_prod('trailblaze','UltraLight Tent 2P','Outdoor','Shelter',399.99,155,1.5,'tent,2person,ultralight,backpacking');
    add_prod('trailblaze','ThermoFlask 32oz','Outdoor','Hydration',44.99,14,0.5,'flask,insulated,32oz,steel');
    add_prod('trailblaze','HeadLamp 1000 Lumens','Outdoor','Lighting',69.99,22,0.12,'headlamp,1000lm,rechargeable,camping');

    -- LuxeThread (Fashion-Luxury)
    add_prod('luxethread','Cashmere Overcoat','Fashion','Outerwear',895.00,320,2.1,'cashmere,overcoat,luxury,winter');
    add_prod('luxethread','Silk Evening Dress','Fashion','Dresses',650.00,230,0.6,'silk,evening,luxury,formal');
    add_prod('luxethread','Italian Leather Loafers','Fashion','Footwear',425.00,165,0.8,'loafers,italian,leather,luxury');
    add_prod('luxethread','Gold Chain Pendant','Fashion','Jewelry',275.00,95,0.05,'pendant,gold,chain,minimalist');
    add_prod('luxethread','Heritage Leather Belt','Fashion','Accessories',195.00,72,0.3,'belt,leather,heritage,brass');

    -- CloudStep (Footwear)
    add_prod('cloudstep','AirGlide Runner','Footwear','Running',149.99,52,0.6,'running,lightweight,cushion,cloud');
    add_prod('cloudstep','StreetFlex Sneaker','Footwear','Casual',119.99,42,0.7,'sneaker,casual,flex,daily');
    add_prod('cloudstep','TrailGrip Hiker','Footwear','Hiking',179.99,65,0.9,'hiking,trail,waterproof,grip');
    add_prod('cloudstep','SlipStream Slide','Footwear','Sandals',49.99,15,0.3,'slide,recovery,comfort,foam');
    add_prod('cloudstep','UrbanDash Trainer','Footwear','Training',134.99,48,0.65,'trainer,gym,versatile,stable');

    -- PixelCraft (Gaming)
    add_prod('pixelcraft','HyperFrame GPU 4080','Gaming','Components',799.99,380,1.8,'gpu,4080,ray-tracing,gaming');
    add_prod('pixelcraft','RGBStorm Gaming Chair','Gaming','Furniture',449.99,165,18,'chair,gaming,rgb,ergonomic');
    add_prod('pixelcraft','SpeedSwitch Controller','Gaming','Controllers',79.99,28,0.3,'controller,wireless,haptic,pc');
    add_prod('pixelcraft','GameStream Capture Card','Gaming','Streaming',199.99,72,0.15,'capture-card,4k,streaming,content');
    add_prod('pixelcraft','UltraWide Curved 34','Gaming','Displays',699.99,280,9.5,'monitor,curved,34inch,165hz');

    -- OmniWear (Wearables-Luxury)
    add_prod('omniwear','OmniRing Health Tracker','Wearables','Rings',349.99,125,0.008,'ring,health,sleep,hrv');
    add_prod('omniwear','OmniGlass AR Glasses','Wearables','Eyewear',1499.99,620,0.05,'ar-glasses,smart,display,navigation');
    add_prod('omniwear','OmniBand Fitness Pro','Wearables','Bands',249.99,85,0.03,'band,fitness,ecg,spo2');
    add_prod('omniwear','OmniPod Audio Earring','Wearables','Audio',599.99,210,0.006,'earring,audio,bluetooth,jewelry');
    add_prod('omniwear','OmniClip Posture Coach','Wearables','Health',129.99,42,0.02,'posture,coach,vibration,clip');

    -- More brands with fewer products each
    -- AtomFit
    add_prod('atomfit','PulseWatch GPS','Wearables','Watches',299.99,105,0.05,'watch,gps,heart-rate,swim');
    add_prod('atomfit','FitScale Pro','Fitness','Scales',99.99,35,2.5,'scale,smart,body-comp,bluetooth');
    add_prod('atomfit','RecoveryGun Mini','Fitness','Recovery',149.99,52,0.6,'massage-gun,mini,percussion');

    -- CrystalView
    add_prod('crystalview','Titanium Aviators','Eyewear','Sunglasses',225.00,82,0.03,'aviator,titanium,polarized');
    add_prod('crystalview','BlueShield Computer Glasses','Eyewear','Computer',89.99,28,0.025,'blue-light,computer,glasses');
    add_prod('crystalview','Sport Wrap Shades','Eyewear','Sport',159.99,55,0.035,'sport,wrap,polarized,running');

    -- ZenBrew
    add_prod('zenbrew','Matcha Starter Kit','Beverages','Tea',49.99,16,0.8,'matcha,kit,whisk,ceremonial');
    add_prod('zenbrew','Cold Brew Tower','Beverages','Coffee',79.99,28,2.5,'cold-brew,tower,glass,slow-drip');
    add_prod('zenbrew','Herbal Sleep Blend','Beverages','Wellness',24.99,7,0.15,'herbal,tea,sleep,chamomile');

    -- IronCore
    add_prod('ironcore','PowerRack Home Gym','Fitness','Equipment',1499.99,580,90,'power-rack,squat,home-gym');
    add_prod('ironcore','Olympic Barbell 45lb','Fitness','Weights',299.99,115,20.4,'barbell,olympic,45lb,steel');
    add_prod('ironcore','Rubber Hex Dumbbells','Fitness','Weights',89.99,32,9.1,'dumbbells,hex,rubber,pair');

    -- EverGreen
    add_prod('evergreen','Solar Phone Charger','Electronics','Chargers',69.99,24,0.3,'solar,charger,portable,eco');
    add_prod('evergreen','Bamboo Laptop Stand','Electronics','Accessories',49.99,16,0.8,'laptop-stand,bamboo,sustainable');
    add_prod('evergreen','Recycled Ocean Tote','Fashion','Bags',45.99,14,0.4,'tote,recycled,ocean-plastic,eco');

    -- PureRoots
    add_prod('pureroots','Adaptogen Blend Powder','Wellness','Supplements',39.99,12,0.25,'adaptogen,ashwagandha,stress');
    add_prod('pureroots','Collagen Peptides','Wellness','Supplements',44.99,14,0.3,'collagen,peptides,skin,joints');
    add_prod('pureroots','Magnesium Sleep Gummies','Wellness','Supplements',29.99,8,0.2,'magnesium,sleep,gummies,relax');

    -- AuraScent
    add_prod('aurascent','Midnight Rose Perfume','Beauty','Fragrance',125.00,38,0.15,'perfume,rose,luxury,evening');
    add_prod('aurascent','Ocean Breeze Candle','Home','Candles',42.99,12,0.5,'candle,ocean,soy,relaxing');
    add_prod('aurascent','Lavender Diffuser Set','Home','Aromatherapy',58.99,18,0.8,'diffuser,lavender,essential-oil');

    -- BoldBrew
    add_prod('boldbrew','Nitro Cold Brew 12-Pack','Beverages','Coffee',48.99,18,5.4,'nitro,cold-brew,canned,bold');
    add_prod('boldbrew','Espresso Blend Beans 2lb','Beverages','Coffee',32.99,11,0.9,'espresso,beans,dark-roast,fresh');
    add_prod('boldbrew','Instant Latte Packets','Beverages','Coffee',19.99,6,0.3,'instant,latte,convenient,travel');

    -- DarkMatter (Gaming)
    add_prod('darkmatter','Nebula RGB Mouse Pad XL','Gaming','Accessories',49.99,15,0.8,'mousepad,xl,rgb,gaming');
    add_prod('darkmatter','VoidStrike Gaming Headset','Gaming','Audio',179.99,62,0.4,'headset,gaming,surround,wireless');
    add_prod('darkmatter','PhantomCase PC Mid Tower','Gaming','Cases',159.99,58,8.5,'case,mid-tower,tempered-glass');

    -- FlameCook
    add_prod('flamecook','Cast Iron Skillet 12"','Kitchen','Cookware',69.99,24,3.5,'cast-iron,skillet,seasoned,12inch');
    add_prod('flamecook','Smart Meat Thermometer','Kitchen','Gadgets',49.99,16,0.08,'thermometer,bluetooth,meat,smart');
    add_prod('flamecook','Knife Set Damascus 8pc','Kitchen','Cutlery',299.99,110,2.8,'knives,damascus,8piece,chef');

    -- HaloVision
    add_prod('halovision','AR Headset Vision Pro','Electronics','AR/VR',2499.99,1100,0.45,'ar-headset,mixed-reality,spatial');
    add_prod('halovision','HoloLens Dock','Electronics','Accessories',199.99,72,0.6,'dock,charging,display,stand');
    add_prod('halovision','Spatial Audio Buds','Audio','Earbuds',299.99,105,0.05,'spatial-audio,earbuds,ar,premium');

    -- Additional products to reach ~250
    add_prod('urbanpulse','Cyber Mesh Sneakers','Footwear','Sneakers',159.99,58,0.7,'sneakers,mesh,cyber,limited');
    add_prod('urbanpulse','Holographic Belt Bag','Fashion','Accessories',64.99,22,0.3,'belt-bag,holographic,festival');
    add_prod('urbanpulse','Oversized Graphic Tee','Fashion','Tops',49.99,15,0.25,'tee,oversized,graphic,unisex');
    add_prod('technova','NovaBuds Sport','Electronics','Audio',149.99,48,0.04,'earbuds,sport,waterproof,secure');
    add_prod('technova','USB-C Cable Pack 3x','Electronics','Accessories',29.99,8,0.15,'cable,usbc,braided,3pack');
    add_prod('glowkin','Retinol Night Cream','Beauty','Skincare',72.99,20,0.12,'retinol,night-cream,anti-aging');
    add_prod('glowkin','Lip Plump Gloss','Beauty','Makeup',22.99,6,0.03,'lip-gloss,plumping,glossy');
    add_prod('peakform','Yoga Mat Premium','Fitness','Yoga',89.99,28,2.5,'yoga-mat,premium,thick,non-slip');
    add_prod('peakform','Pull-Up Bar Doorway','Fitness','Equipment',44.99,14,2.8,'pull-up-bar,doorway,portable');
    add_prod('nestcraft','Ceramic Vase Set','Home','Decor',69.99,22,1.8,'vase,ceramic,set,modern');
    add_prod('nestcraft','LED Desk Lamp','Home','Lighting',54.99,18,1.2,'desk-lamp,led,dimmable,usb');
    add_prod('voltedge','Portable SSD 2TB','Electronics','Storage',179.99,65,0.08,'ssd,2tb,portable,usbc');
    add_prod('voltedge','Wi-Fi 7 Router','Electronics','Networking',299.99,110,0.9,'router,wifi7,mesh,fast');
    add_prod('sonicwave','Vinyl Turntable','Audio','Turntables',249.99,88,5.5,'turntable,vinyl,bluetooth,retro');
    add_prod('sonicwave','Karaoke System','Audio','Systems',199.99,72,3.8,'karaoke,wireless-mic,bluetooth');
    add_prod('trailblaze','Camping Hammock','Outdoor','Shelter',59.99,18,0.6,'hammock,camping,lightweight,nylon');
    add_prod('trailblaze','Trekking Poles Carbon','Outdoor','Accessories',119.99,42,0.5,'trekking-poles,carbon,folding');
    add_prod('luxethread','Merino Wool Scarf','Fashion','Accessories',145.00,52,0.2,'scarf,merino,luxury,winter');
    add_prod('cloudstep','WinterGrip Boot','Footwear','Boots',199.99,72,1.1,'boot,winter,insulated,waterproof');
    add_prod('pixelcraft','Streaming Deck 15-Key','Gaming','Streaming',129.99,45,0.3,'stream-deck,15key,macro,content');
    add_prod('omniwear','OmniSleep Mask','Wearables','Sleep',199.99,68,0.05,'sleep-mask,smart,light-therapy');
    add_prod('frostbyte','Cryo Laptop Cooler','Electronics','Cooling',79.99,28,1.2,'laptop-cooler,fan,rgb,quiet');
    add_prod('frostbyte','Ice Crystal Keyboard','Electronics','Peripherals',149.99,52,0.85,'keyboard,transparent,mechanical,rgb');
    add_prod('frostbyte','SubZero Webcam Ring Light','Electronics','Lighting',39.99,12,0.3,'ring-light,webcam,led,clip');
    add_prod('wildroam','Travel Organizer Cube Set','Travel','Accessories',34.99,10,0.4,'packing-cubes,travel,organizer');
    add_prod('wildroam','Neck Pillow Memory Foam','Travel','Comfort',29.99,8,0.3,'neck-pillow,memory-foam,travel');
    add_prod('wildroam','RFID Blocking Passport Wallet','Travel','Security',24.99,7,0.1,'wallet,rfid,passport,travel');
    add_prod('flexihome','Smart LED Strip 5M','Home','Lighting',34.99,10,0.3,'led-strip,smart,rgb,alexa');
    add_prod('flexihome','Modular Shelf System','Home','Furniture',199.99,72,12,'shelf,modular,wall-mount,modern');
    add_prod('flexihome','Robot Vacuum V3','Home','Appliances',399.99,155,3.5,'robot-vacuum,smart,lidar,mapping');
    add_prod('moonglow','Starlight Eye Palette','Beauty','Makeup',38.99,10,0.1,'eye-palette,shimmer,starlight');
    add_prod('moonglow','Moonbeam Highlighter','Beauty','Makeup',28.99,7,0.08,'highlighter,moonbeam,glow,holographic');
    add_prod('terragear','Climbing Harness Pro','Outdoor','Climbing',129.99,45,0.5,'harness,climbing,lightweight,safe');
    add_prod('terragear','4-Season Tent 3P','Outdoor','Shelter',549.99,215,2.8,'tent,4-season,3person,alpine');
    add_prod('neonnight','LED Festival Jacket','Fashion','Outerwear',149.99,52,0.8,'jacket,led,festival,glow');
    add_prod('neonnight','UV Reactive Crop Top','Fashion','Tops',39.99,12,0.15,'crop-top,uv,reactive,rave');
    add_prod('aquafit','Swim Tracker Watch','Fitness','Wearables',179.99,62,0.04,'swim-watch,waterproof,lap-counter');
    add_prod('aquafit','Underwater MP3 Player','Audio','Waterproof',69.99,24,0.03,'mp3,waterproof,swim,earbuds');
    add_prod('stridepro','Marathon Elite Racer','Footwear','Running',219.99,78,0.22,'racing-shoe,marathon,carbon-plate');
    add_prod('stridepro','CrossFit WOD Trainer','Footwear','Training',159.99,55,0.65,'crossfit,trainer,stable,durable');
    add_prod('novaskin','Probiotic Face Wash','Beauty','Skincare',32.99,9,0.2,'face-wash,probiotic,gentle,ph');
    add_prod('novaskin','SPF50 Invisible Sunscreen','Beauty','Skincare',28.99,8,0.1,'sunscreen,spf50,invisible,daily');
    add_prod('thunderlift','Adjustable Bench','Fitness','Equipment',349.99,125,22,'bench,adjustable,flat-incline');
    add_prod('thunderlift','Battle Ropes 50ft','Fitness','Equipment',119.99,42,11,'battle-ropes,50ft,conditioning');
    add_prod('rustichome','Reclaimed Wood Table','Home','Furniture',699.99,280,25,'table,reclaimed-wood,rustic,dining');
    add_prod('rustichome','Mason Jar Lights','Home','Lighting',34.99,10,0.5,'lights,mason-jar,rustic,fairy');
    add_prod('electravibe','Portable DJ Controller','Audio','DJ','299.99',105,2.2,'dj-controller,portable,usb,midi');
    add_prod('electravibe','Bluetooth Turntable Speakers','Audio','Speakers',179.99,62,4.5,'turntable,speakers,bluetooth,retro');
    add_prod('zephyrwind','Ultralight Rain Jacket','Outdoor','Outerwear',149.99,52,0.2,'rain-jacket,ultralight,packable');
    add_prod('zephyrwind','Trekking Backpack 45L','Outdoor','Backpacks',179.99,65,1.4,'backpack,45L,trekking,ventilated');
    add_prod('quantumleap','Quantum Processor Desktop','Electronics','Computers',3999.99,1800,12,'desktop,quantum,ai,workstation');
    add_prod('quantumleap','Neural Interface Dev Kit','Electronics','Development',799.99,320,0.8,'neural,dev-kit,bci,research');
    add_prod('silkveil','Silk Sleep Set','Fashion','Sleepwear',175.00,62,0.35,'silk,sleep-set,pajamas,luxury');
    add_prod('silkveil','Cashmere Beanie','Fashion','Accessories',89.00,30,0.08,'beanie,cashmere,winter,soft');
    add_prod('flamecook','Air Fryer Pro 6Qt','Kitchen','Appliances',129.99,45,5.5,'air-fryer,6qt,digital,healthy');
    add_prod('flamecook','Pour-Over Kettle Gooseneck','Kitchen','Coffee',59.99,20,0.8,'kettle,gooseneck,pour-over,temp');
    add_prod('mindfultech','Meditation Headband','Wellness','Devices',199.99,72,0.06,'meditation,eeg,headband,calm');
    add_prod('mindfultech','Smart Journal Pen','Wellness','Stationery',129.99,45,0.03,'smart-pen,journal,digitize,notes');
    add_prod('apexride','Carbon Road Bike','Sports','Cycling',2899.99,1250,7.8,'road-bike,carbon,shimano,race');
    add_prod('apexride','Bike Computer GPS','Sports','Accessories',249.99,88,0.08,'bike-computer,gps,strava,cadence');
    add_prod('darkmatter','GravityDesk Gaming Desk','Gaming','Furniture',349.99,125,28,'desk,gaming,cable-mgmt,led');
    add_prod('darkmatter','PortalView Portable Monitor','Gaming','Displays',279.99,98,0.8,'monitor,portable,15inch,usbc');
    add_prod('goldenharvest','Organic Protein Bars 12pk','Food','Snacks',34.99,12,0.8,'protein-bar,organic,12pack');
    add_prod('goldenharvest','Artisan Granola Trio','Food','Breakfast',27.99,9,1.2,'granola,artisan,trio,organic');
    add_prod('goldenharvest','Superfood Trail Mix','Food','Snacks',19.99,6,0.5,'trail-mix,superfood,nuts,berries');
    add_prod('nightowl','Midnight Espresso Blend','Beverages','Coffee',24.99,7,0.34,'espresso,dark,midnight,beans');
    add_prod('nightowl','Energy Matcha Shots 6pk','Beverages','Energy',21.99,7,0.6,'matcha,energy,shots,natural');
    add_prod('clearpath','CBD Recovery Balm','Wellness','Recovery',54.99,18,0.1,'cbd,balm,recovery,muscle');
    add_prod('clearpath','Breathwork Timer Device','Wellness','Devices',89.99,30,0.05,'breathwork,timer,meditation');
    add_prod('steelgrip','Multi-Tool Pro 18-in-1','Tools','Multi-tools',49.99,16,0.25,'multi-tool,18in1,stainless');
    add_prod('steelgrip','Impact Driver 20V','Tools','Power Tools',179.99,62,1.8,'impact-driver,20v,brushless');
    add_prod('lunawear','Crescent Moon Earrings','Fashion','Jewelry',48.99,14,0.01,'earrings,moon,silver,dainty');
    add_prod('lunawear','Tie-Dye Maxi Dress','Fashion','Dresses',79.99,28,0.4,'maxi-dress,tie-dye,summer');
    add_prod('rapidcharge','GaN Charger 100W','Electronics','Chargers',59.99,18,0.15,'charger,100w,gan,compact');
    add_prod('rapidcharge','Wireless Charging Pad Duo','Electronics','Chargers',44.99,14,0.2,'wireless-charger,duo,qi,fast');
    add_prod('verdelife','Reusable Beeswax Wraps','Home','Kitchen',18.99,5,0.12,'beeswax-wraps,reusable,eco');
    add_prod('verdelife','Compost Bin Smart','Home','Garden',89.99,32,3.5,'compost,smart,indoor,odorless');
    add_prod('coralreef','Ocean Plastic Sunglasses','Eyewear','Sunglasses',79.99,24,0.035,'sunglasses,ocean-plastic,recycled');
    add_prod('coralreef','Reef-Safe Sunscreen SPF30','Beauty','Suncare',24.99,7,0.12,'sunscreen,reef-safe,spf30,mineral');
    add_prod('bytebite','Smart Food Scale','Kitchen','Gadgets',69.99,24,0.5,'food-scale,smart,nutrition,app');
    add_prod('bytebite','Meal Prep Container Set','Kitchen','Storage',29.99,9,1.2,'meal-prep,containers,glass,set');
    -- Reach 150+ unique products

    -- Additional variety
    add_prod('urbanpulse','Graffiti Art Hoodie','Fashion','Tops',94.99,34,0.65,'hoodie,graffiti,art,limited-edition');
    add_prod('technova','NovaCam Action 5K','Electronics','Cameras',399.99,155,0.15,'action-cam,5k,stabilized,waterproof');
    add_prod('glowkin','Overnight Recovery Mask','Beauty','Skincare',48.99,13,0.1,'mask,overnight,recovery,hydrating');
    add_prod('peakform','Smart Jump Rope','Fitness','Accessories',39.99,12,0.3,'jump-rope,smart,counter,app');
    add_prod('sonicwave','Outdoor Party Speaker','Audio','Speakers',399.99,145,8,'speaker,party,outdoor,waterproof');
    add_prod('trailblaze','Solar Lantern Collapsible','Outdoor','Lighting',29.99,8,0.2,'lantern,solar,collapsible,camping');
    add_prod('cloudstep','Barefoot Minimalist Shoe','Footwear','Minimalist',99.99,35,0.2,'barefoot,minimalist,flexible,natural');
    add_prod('pixelcraft','RGB Desk Pad XXL','Gaming','Accessories',39.99,12,0.6,'desk-pad,xxl,rgb,stitched');
    add_prod('omniwear','OmniCharge Solar Watch','Wearables','Watches',499.99,180,0.055,'watch,solar,smart,titanium');
    add_prod('aquafit','Resistance Pool Bands','Fitness','Pool',44.99,14,0.8,'pool,resistance,bands,aquatic');
    add_prod('stridepro','Recovery Slide Foam','Footwear','Recovery',64.99,22,0.35,'slide,recovery,foam,post-run');
    add_prod('novaskin','Niacinamide Pore Serum','Beauty','Skincare',26.99,7,0.08,'niacinamide,pore,serum,oil-control');
    add_prod('rustichome','Handmade Ceramic Bowl Set','Home','Kitchen',89.99,30,3.5,'bowls,ceramic,handmade,artisan');

    FOR i IN 1..v_prods.COUNT LOOP
        BEGIN
            SELECT brand_id INTO v_brand_id
            FROM brands
            WHERE brand_slug = v_prods(i).bslug;

            v_idx := v_idx + 1;
            v_sku := UPPER(SUBSTR(v_prods(i).bslug, 1, 3)) || '-' ||
                     LPAD(v_idx, 5, '0');

            INSERT INTO products (brand_id, sku, product_name, category, subcategory,
                                  unit_price, unit_cost, weight_kg, tags, launch_date)
            VALUES (v_brand_id, v_sku, v_prods(i).pname, v_prods(i).cat, v_prods(i).subcat,
                    v_prods(i).price, v_prods(i).cost, v_prods(i).wt, v_prods(i).tags,
                    SYSDATE - DBMS_RANDOM.VALUE(30, 730));
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN NULL;  -- skip dupes
        END;
    END LOOP;

    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Products loaded: ' || v_idx);
END;
/

-- ============================================================
-- GENERATE INVENTORY (each product stocked at 5-15 random centers)
-- ============================================================
PROMPT Generating inventory...

DECLARE
    v_count       NUMBER := 0;
    v_num_centers NUMBER;
BEGIN
    FOR p IN (SELECT product_id FROM products) LOOP
        v_num_centers := FLOOR(DBMS_RANDOM.VALUE(5, 16));
        FOR c IN (
            SELECT center_id FROM (
                SELECT center_id FROM fulfillment_centers
                ORDER BY DBMS_RANDOM.VALUE
            ) WHERE ROWNUM <= v_num_centers
        ) LOOP
            BEGIN
                INSERT INTO inventory (product_id, center_id, quantity_on_hand,
                                       quantity_reserved, reorder_point, reorder_qty,
                                       last_restock_date)
                VALUES (p.product_id, c.center_id,
                        FLOOR(DBMS_RANDOM.VALUE(10, 500)),
                        FLOOR(DBMS_RANDOM.VALUE(0, 30)),
                        FLOOR(DBMS_RANDOM.VALUE(20, 100)),
                        FLOOR(DBMS_RANDOM.VALUE(100, 500)),
                        SYSDATE - DBMS_RANDOM.VALUE(1, 30));
                v_count := v_count + 1;
            EXCEPTION
                WHEN DUP_VAL_ON_INDEX THEN NULL;
            END;
        END LOOP;
    END LOOP;
    COMMIT;
    DBMS_OUTPUT.PUT_LINE('Inventory records loaded: ' || v_count);
END;
/
