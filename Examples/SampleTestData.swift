//
// Copyright (c) Beyoug
//

import Foundation

/// 静态测试数据 - 200条边界测试数据
/// 包含不同长度的subtitle和随机尺寸的图片，用于全面测试瀑布流布局
public struct SampleTestData {
    
    /// 200条测试数据，包含：
    /// - 短文本subtitle (≤15字): 159条
    /// - 中等文本subtitle (16-45字): 8条  
    /// - 长文本subtitle (>45字): 33条
    /// - 随机图片尺寸 (220-380 x 160-460): 200条
    public static let testItems: [SampleDataItem] = [
        SampleDataItem(
            id: 1,
            title: "春日樱花盛开",
            subtitle: "建筑奇观",
            type: "风景",
            imageUrl: "https://picsum.photos/356/435?random=1",
            metadata: ["春天", "樱花", "浪漫"]
        ),
        SampleDataItem(
            id: 2,
            title: "现代建筑设计",
            subtitle: "创意无限",
            type: "建筑",
            imageUrl: "https://picsum.photos/239/374?random=2",
            metadata: ["现代", "设计", "艺术"]
        ),
        SampleDataItem(
            id: 3,
            title: "美味意大利面",
            subtitle: "动物世界充满了神奇与美妙，每一种生物都有其独特的生存智慧和生命魅力，它们与人类共同构成了这个多彩的地球家园。",
            type: "美食",
            imageUrl: "https://picsum.photos/298/165?random=3",
            metadata: ["意大利", "面条", "美味"]
        ),
        SampleDataItem(
            id: 4,
            title: "可爱的小猫咪",
            subtitle: "浪漫情怀",
            type: "动物",
            imageUrl: "https://picsum.photos/312/169?random=4",
            metadata: ["猫咪", "可爱", "宠物"]
        ),
        SampleDataItem(
            id: 5,
            title: "山间徒步之旅",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "户外",
            imageUrl: "https://picsum.photos/366/280?random=5",
            metadata: ["徒步", "山脉", "冒险"]
        ),
        SampleDataItem(
            id: 6,
            title: "绿色多肉植物",
            subtitle: "典雅风范",
            type: "植物",
            imageUrl: "https://picsum.photos/378/388?random=6",
            metadata: ["多肉", "绿植", "装饰"]
        ),
        SampleDataItem(
            id: 7,
            title: "抽象艺术作品",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "艺术",
            imageUrl: "https://picsum.photos/380/398?random=7",
            metadata: ["抽象", "色彩", "创意"]
        ),
        SampleDataItem(
            id: 8,
            title: "智能手机新品",
            subtitle: "宁静的环境让心灵得到放松",
            type: "科技",
            imageUrl: "https://picsum.photos/246/192?random=8",
            metadata: ["手机", "科技", "创新"]
        ),
        SampleDataItem(
            id: 9,
            title: "夕阳西下海滩",
            subtitle: "宁静的环境让心灵得到放松",
            type: "风景",
            imageUrl: "https://picsum.photos/327/203?random=9",
            metadata: ["夕阳", "海滩", "浪漫"]
        ),
        SampleDataItem(
            id: 10,
            title: "古典欧式建筑",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "建筑",
            imageUrl: "https://picsum.photos/330/315?random=10",
            metadata: ["古典", "欧式", "历史"]
        ),
        SampleDataItem(
            id: 11,
            title: "日式拉面",
            subtitle: "温馨时光",
            type: "美食",
            imageUrl: "https://picsum.photos/271/393?random=11",
            metadata: ["日式", "拉面", "汤面"]
        ),
        SampleDataItem(
            id: 12,
            title: "金毛犬在草地",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "动物",
            imageUrl: "https://picsum.photos/327/451?random=12",
            metadata: ["金毛", "草地", "阳光"]
        ),
        SampleDataItem(
            id: 13,
            title: "露营星空夜",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "户外",
            imageUrl: "https://picsum.photos/297/308?random=13",
            metadata: ["露营", "星空", "夜晚"]
        ),
        SampleDataItem(
            id: 14,
            title: "向日葵花田",
            subtitle: "清新自然",
            type: "植物",
            imageUrl: "https://picsum.photos/272/207?random=14",
            metadata: ["向日葵", "花田", "金黄"]
        ),
        SampleDataItem(
            id: 15,
            title: "水彩画风景",
            subtitle: "色彩斑斓",
            type: "艺术",
            imageUrl: "https://picsum.photos/347/341?random=15",
            metadata: ["水彩", "风景", "诗意"]
        ),
        SampleDataItem(
            id: 16,
            title: "无人机航拍",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "科技",
            imageUrl: "https://picsum.photos/282/250?random=16",
            metadata: ["无人机", "航拍", "技术"]
        ),
        SampleDataItem(
            id: 17,
            title: "秋日枫叶林",
            subtitle: "色彩斑斓",
            type: "风景",
            imageUrl: "https://picsum.photos/283/416?random=17",
            metadata: ["秋天", "枫叶", "色彩"]
        ),
        SampleDataItem(
            id: 18,
            title: "摩天大楼群",
            subtitle: "匠心独运",
            type: "建筑",
            imageUrl: "https://picsum.photos/254/264?random=18",
            metadata: ["摩天楼", "都市", "现代"]
        ),
        SampleDataItem(
            id: 19,
            title: "法式甜点",
            subtitle: "和谐之美",
            type: "美食",
            imageUrl: "https://picsum.photos/231/192?random=19",
            metadata: ["法式", "甜点", "精致"]
        ),
        SampleDataItem(
            id: 20,
            title: "海豚跃出水面",
            subtitle: "和谐的搭配创造出完美的效果",
            type: "动物",
            imageUrl: "https://picsum.photos/357/318?random=20",
            metadata: ["海豚", "海洋", "跳跃"]
        ),
        SampleDataItem(
            id: 21,
            title: "雪山日出",
            subtitle: "现代科技改变着我们的生活方式",
            type: "风景",
            imageUrl: "https://picsum.photos/358/264?random=21",
            metadata: ["雪山", "日出", "壮美"]
        ),
        SampleDataItem(
            id: 22,
            title: "湖光山色",
            subtitle: "建筑是人类文明的重要载体，每一座建筑都承载着特定的历史文化内涵，展现着不同时代的审美理念和技术水平。",
            type: "风景",
            imageUrl: "https://picsum.photos/286/351?random=22",
            metadata: ["湖泊", "山色", "宁静"]
        ),
        SampleDataItem(
            id: 23,
            title: "沙漠驼队",
            subtitle: "优雅格调",
            type: "风景",
            imageUrl: "https://picsum.photos/221/451?random=23",
            metadata: ["沙漠", "驼队", "足迹"]
        ),
        SampleDataItem(
            id: 24,
            title: "瀑布飞流",
            subtitle: "清新自然",
            type: "风景",
            imageUrl: "https://picsum.photos/277/404?random=24",
            metadata: ["瀑布", "飞流", "水花"]
        ),
        SampleDataItem(
            id: 25,
            title: "草原牧歌",
            subtitle: "精致的设计展现了独特的艺术风格",
            type: "风景",
            imageUrl: "https://picsum.photos/319/211?random=25",
            metadata: ["草原", "牧歌", "牛羊"]
        ),
        SampleDataItem(
            id: 26,
            title: "竹林幽径",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "风景",
            imageUrl: "https://picsum.photos/253/387?random=26",
            metadata: ["竹林", "幽径", "光影"]
        ),
        SampleDataItem(
            id: 27,
            title: "海岸礁石",
            subtitle: "宁静的环境让心灵得到放松",
            type: "风景",
            imageUrl: "https://picsum.photos/373/322?random=27",
            metadata: ["海岸", "礁石", "海鸟"]
        ),
        SampleDataItem(
            id: 28,
            title: "田园风光",
            subtitle: "动物世界",
            type: "风景",
            imageUrl: "https://picsum.photos/353/223?random=28",
            metadata: ["田园", "麦田", "农舍"]
        ),
        SampleDataItem(
            id: 29,
            title: "古代宫殿",
            subtitle: "可爱的动物们展现着生命的活力",
            type: "建筑",
            imageUrl: "https://picsum.photos/325/386?random=29",
            metadata: ["古代", "宫殿", "工艺"]
        ),
        SampleDataItem(
            id: 30,
            title: "现代桥梁",
            subtitle: "宁静致远",
            type: "建筑",
            imageUrl: "https://picsum.photos/266/188?random=30",
            metadata: ["现代", "桥梁", "工程"]
        ),
        SampleDataItem(
            id: 31,
            title: "教堂尖塔",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "建筑",
            imageUrl: "https://picsum.photos/309/373?random=31",
            metadata: ["教堂", "尖塔", "彩窗"]
        ),
        SampleDataItem(
            id: 32,
            title: "传统民居",
            subtitle: "精美的作品展示了高超的技艺",
            type: "建筑",
            imageUrl: "https://picsum.photos/223/271?random=32",
            metadata: ["传统", "民居", "历史"]
        ),
        SampleDataItem(
            id: 33,
            title: "现代办公楼",
            subtitle: "和谐的搭配创造出完美的效果",
            type: "建筑",
            imageUrl: "https://picsum.photos/380/226?random=33",
            metadata: ["现代", "办公楼", "都市"]
        ),
        SampleDataItem(
            id: 34,
            title: "古塔建筑",
            subtitle: "典雅风范",
            type: "建筑",
            imageUrl: "https://picsum.photos/377/452?random=34",
            metadata: ["古塔", "千年", "文化"]
        ),
        SampleDataItem(
            id: 35,
            title: "园林亭台",
            subtitle: "诗意生活",
            type: "建筑",
            imageUrl: "https://picsum.photos/376/275?random=35",
            metadata: ["园林", "亭台", "造园"]
        ),
        SampleDataItem(
            id: 36,
            title: "现代体育馆",
            subtitle: "匠心独运",
            type: "建筑",
            imageUrl: "https://picsum.photos/331/426?random=36",
            metadata: ["体育馆", "流线型", "技术"]
        ),
        SampleDataItem(
            id: 37,
            title: "川菜麻辣锅",
            subtitle: "美味佳肴",
            type: "美食",
            imageUrl: "https://picsum.photos/371/416?random=37",
            metadata: ["川菜", "麻辣", "香辣"]
        ),
        SampleDataItem(
            id: 38,
            title: "粤式点心",
            subtitle: "美味佳肴",
            type: "美食",
            imageUrl: "https://picsum.photos/368/426?random=38",
            metadata: ["粤式", "点心", "茶点"]
        ),
        SampleDataItem(
            id: 39,
            title: "北京烤鸭",
            subtitle: "科技前沿",
            type: "美食",
            imageUrl: "https://picsum.photos/353/304?random=39",
            metadata: ["北京", "烤鸭", "酥脆"]
        ),
        SampleDataItem(
            id: 40,
            title: "日式寿司",
            subtitle: "宁静的环境让心灵得到放松",
            type: "美食",
            imageUrl: "https://picsum.photos/220/265?random=40",
            metadata: ["日式", "寿司", "生鱼片"]
        ),
        SampleDataItem(
            id: 41,
            title: "意式披萨",
            subtitle: "现代科技改变着我们的生活方式",
            type: "美食",
            imageUrl: "https://picsum.photos/375/194?random=41",
            metadata: ["意式", "披萨", "奶酪"]
        ),
        SampleDataItem(
            id: 42,
            title: "法式牛排",
            subtitle: "充满活力的场景令人心情愉悦",
            type: "美食",
            imageUrl: "https://picsum.photos/239/394?random=42",
            metadata: ["法式", "牛排", "红酒"]
        ),
        SampleDataItem(
            id: 43,
            title: "韩式烤肉",
            subtitle: "植物生机",
            type: "美食",
            imageUrl: "https://picsum.photos/331/256?random=43",
            metadata: ["韩式", "烤肉", "炭火"]
        ),
        SampleDataItem(
            id: 44,
            title: "泰式咖喱",
            subtitle: "户外探险",
            type: "美食",
            imageUrl: "https://picsum.photos/273/455?random=44",
            metadata: ["泰式", "咖喱", "椰浆"]
        ),
        SampleDataItem(
            id: 45,
            title: "熊猫宝宝",
            subtitle: "现代科技改变着我们的生活方式",
            type: "动物",
            imageUrl: "https://picsum.photos/325/292?random=45",
            metadata: ["熊猫", "宝宝", "竹林"]
        ),
        SampleDataItem(
            id: 46,
            title: "雄鹰翱翔",
            subtitle: "现代设计",
            type: "动物",
            imageUrl: "https://picsum.photos/226/243?random=46",
            metadata: ["雄鹰", "翱翔", "王者"]
        ),
        SampleDataItem(
            id: 47,
            title: "小鹿斑比",
            subtitle: "这件精美的艺术作品凝聚了创作者的心血与智慧，通过独特的表现手法和深刻的内涵，向观者传达着丰富的情感和深邃的思想，是艺术与生活完美结合的典范。",
            type: "动物",
            imageUrl: "https://picsum.photos/332/414?random=47",
            metadata: ["小鹿", "森林", "溪边"]
        ),
        SampleDataItem(
            id: 48,
            title: "企鹅家族",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "动物",
            imageUrl: "https://picsum.photos/307/434?random=48",
            metadata: ["企鹅", "南极", "家族"]
        ),
        SampleDataItem(
            id: 49,
            title: "狮子王者",
            subtitle: "宁静的环境让心灵得到放松",
            type: "动物",
            imageUrl: "https://picsum.photos/355/187?random=49",
            metadata: ["狮子", "草原", "王者"]
        ),
        SampleDataItem(
            id: 50,
            title: "蝴蝶花间",
            subtitle: "清新自然",
            type: "动物",
            imageUrl: "https://picsum.photos/309/193?random=50",
            metadata: ["蝴蝶", "花间", "翩翩"]
        ),
        SampleDataItem(
            id: 51,
            title: "海龟游泳",
            subtitle: "户外运动让人感受到自由的快乐",
            type: "动物",
            imageUrl: "https://picsum.photos/258/315?random=51",
            metadata: ["海龟", "海水", "智慧"]
        ),
        SampleDataItem(
            id: 52,
            title: "松鼠觅食",
            subtitle: "户外运动让人感受到自由的快乐",
            type: "动物",
            imageUrl: "https://picsum.photos/372/454?random=52",
            metadata: ["松鼠", "觅食", "坚果"]
        ),
        SampleDataItem(
            id: 53,
            title: "登山征途",
            subtitle: "丰富的色彩构成了美丽的画面",
            type: "户外",
            imageUrl: "https://picsum.photos/377/223?random=53",
            metadata: ["登山", "征途", "挑战"]
        ),
        SampleDataItem(
            id: 54,
            title: "海边冲浪",
            subtitle: "动物世界充满了神奇与美妙，每一种生物都有其独特的生存智慧和生命魅力，它们与人类共同构成了这个多彩的地球家园。",
            type: "户外",
            imageUrl: "https://picsum.photos/363/200?random=54",
            metadata: ["冲浪", "海浪", "搏击"]
        ),
        SampleDataItem(
            id: 55,
            title: "森林探险",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "户外",
            imageUrl: "https://picsum.photos/328/442?random=55",
            metadata: ["森林", "探险", "神秘"]
        ),
        SampleDataItem(
            id: 56,
            title: "沙漠穿越",
            subtitle: "动物世界",
            type: "户外",
            imageUrl: "https://picsum.photos/376/222?random=56",
            metadata: ["沙漠", "穿越", "生存"]
        ),
        SampleDataItem(
            id: 57,
            title: "攀岩运动",
            subtitle: "自然风光",
            type: "户外",
            imageUrl: "https://picsum.photos/305/197?random=57",
            metadata: ["攀岩", "岩壁", "勇气"]
        ),
        SampleDataItem(
            id: 58,
            title: "野外露营",
            subtitle: "丰富的色彩构成了美丽的画面",
            type: "户外",
            imageUrl: "https://picsum.photos/296/419?random=58",
            metadata: ["露营", "篝火", "星空"]
        ),
        SampleDataItem(
            id: 59,
            title: "漂流冒险",
            subtitle: "浪漫情怀",
            type: "户外",
            imageUrl: "https://picsum.photos/327/355?random=59",
            metadata: ["漂流", "河流", "刺激"]
        ),
        SampleDataItem(
            id: 60,
            title: "滑雪运动",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "户外",
            imageUrl: "https://picsum.photos/300/423?random=60",
            metadata: ["滑雪", "山坡", "激情"]
        ),
        SampleDataItem(
            id: 61,
            title: "樱花盛开",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "植物",
            imageUrl: "https://picsum.photos/278/341?random=61",
            metadata: ["樱花", "盛开", "春日"]
        ),
        SampleDataItem(
            id: 62,
            title: "荷花池塘",
            subtitle: "和谐之美",
            type: "植物",
            imageUrl: "https://picsum.photos/376/245?random=62",
            metadata: ["荷花", "池塘", "清雅"]
        ),
        SampleDataItem(
            id: 63,
            title: "梅花傲雪",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "植物",
            imageUrl: "https://picsum.photos/343/330?random=63",
            metadata: ["梅花", "傲雪", "寒冬"]
        ),
        SampleDataItem(
            id: 64,
            title: "玫瑰花园",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "植物",
            imageUrl: "https://picsum.photos/299/178?random=64",
            metadata: ["玫瑰", "花园", "花香"]
        ),
        SampleDataItem(
            id: 65,
            title: "竹子青翠",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "植物",
            imageUrl: "https://picsum.photos/238/168?random=65",
            metadata: ["竹子", "青翠", "坚韧"]
        ),
        SampleDataItem(
            id: 66,
            title: "松树苍劲",
            subtitle: "科技前沿",
            type: "植物",
            imageUrl: "https://picsum.photos/260/285?random=66",
            metadata: ["松树", "苍劲", "生命力"]
        ),
        SampleDataItem(
            id: 67,
            title: "薰衣草田",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "植物",
            imageUrl: "https://picsum.photos/319/419?random=67",
            metadata: ["薰衣草", "紫色", "香气"]
        ),
        SampleDataItem(
            id: 68,
            title: "仙人掌花",
            subtitle: "绿色植物为世界增添了无限生机",
            type: "植物",
            imageUrl: "https://picsum.photos/357/409?random=68",
            metadata: ["仙人掌", "沙漠", "奇迹"]
        ),
        SampleDataItem(
            id: 69,
            title: "油画风景",
            subtitle: "和谐的搭配创造出完美的效果",
            type: "艺术",
            imageUrl: "https://picsum.photos/364/318?random=69",
            metadata: ["油画", "风景", "情感"]
        ),
        SampleDataItem(
            id: 70,
            title: "雕塑艺术",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "艺术",
            imageUrl: "https://picsum.photos/251/397?random=70",
            metadata: ["雕塑", "技艺", "理念"]
        ),
        SampleDataItem(
            id: 71,
            title: "书法作品",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "艺术",
            imageUrl: "https://picsum.photos/249/387?random=71",
            metadata: ["书法", "飘逸", "文化"]
        ),
        SampleDataItem(
            id: 72,
            title: "陶瓷艺术",
            subtitle: "可爱的动物们展现着生命的活力",
            type: "艺术",
            imageUrl: "https://picsum.photos/240/351?random=72",
            metadata: ["陶瓷", "造型", "工艺"]
        ),
        SampleDataItem(
            id: 73,
            title: "摄影作品",
            subtitle: "美味佳肴",
            type: "艺术",
            imageUrl: "https://picsum.photos/283/420?random=73",
            metadata: ["摄影", "黑白", "光影"]
        ),
        SampleDataItem(
            id: 74,
            title: "版画印刷",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "艺术",
            imageUrl: "https://picsum.photos/365/211?random=74",
            metadata: ["版画", "传统", "典雅"]
        ),
        SampleDataItem(
            id: 75,
            title: "现代装置",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "艺术",
            imageUrl: "https://picsum.photos/241/207?random=75",
            metadata: ["装置", "前卫", "空间"]
        ),
        SampleDataItem(
            id: 76,
            title: "民间剪纸",
            subtitle: "创意无限",
            type: "艺术",
            imageUrl: "https://picsum.photos/317/378?random=76",
            metadata: ["剪纸", "民间", "吉祥"]
        ),
        SampleDataItem(
            id: 77,
            title: "人工智能",
            subtitle: "精致工艺",
            type: "科技",
            imageUrl: "https://picsum.photos/368/191?random=77",
            metadata: ["人工智能", "技术", "便利"]
        ),
        SampleDataItem(
            id: 78,
            title: "虚拟现实",
            subtitle: "和谐之美",
            type: "科技",
            imageUrl: "https://picsum.photos/289/271?random=78",
            metadata: ["虚拟现实", "沉浸式", "数字"]
        ),
        SampleDataItem(
            id: 79,
            title: "机器人技术",
            subtitle: "宁静的环境让心灵得到放松",
            type: "科技",
            imageUrl: "https://picsum.photos/241/250?random=79",
            metadata: ["机器人", "智能", "服务"]
        ),
        SampleDataItem(
            id: 80,
            title: "5G通信",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "科技",
            imageUrl: "https://picsum.photos/335/381?random=80",
            metadata: ["5G", "通信", "革命"]
        ),
        SampleDataItem(
            id: 81,
            title: "电动汽车",
            subtitle: "清新自然",
            type: "科技",
            imageUrl: "https://picsum.photos/275/214?random=81",
            metadata: ["电动", "汽车", "环保"]
        ),
        SampleDataItem(
            id: 82,
            title: "太空探索",
            subtitle: "在这个充满诗意的季节里，大自然展现出她最美丽的一面，每一处风景都如画卷般令人陶醉，让我们在忙碌的生活中找到片刻的宁静与美好。",
            type: "科技",
            imageUrl: "https://picsum.photos/318/324?random=82",
            metadata: ["太空", "探索", "火箭"]
        ),
        SampleDataItem(
            id: 83,
            title: "生物技术",
            subtitle: "户外运动让人感受到自由的快乐",
            type: "科技",
            imageUrl: "https://picsum.photos/308/188?random=83",
            metadata: ["生物", "医学", "治疗"]
        ),
        SampleDataItem(
            id: 84,
            title: "量子计算",
            subtitle: "动物世界",
            type: "科技",
            imageUrl: "https://picsum.photos/320/188?random=84",
            metadata: ["量子", "计算", "提升"]
        ),
        SampleDataItem(
            id: 85,
            title: "攀岩运动 65",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "户外",
            imageUrl: "https://picsum.photos/348/219?random=85",
            metadata: ["攀岩", "岩壁", "勇气"]
        ),
        SampleDataItem(
            id: 86,
            title: "泰式咖喱 66",
            subtitle: "匠心独运",
            type: "美食",
            imageUrl: "https://picsum.photos/236/271?random=86",
            metadata: ["泰式", "咖喱", "椰浆"]
        ),
        SampleDataItem(
            id: 87,
            title: "摄影作品 67",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "艺术",
            imageUrl: "https://picsum.photos/266/400?random=87",
            metadata: ["摄影", "黑白", "光影"]
        ),
        SampleDataItem(
            id: 88,
            title: "版画印刷 68",
            subtitle: "创意无限",
            type: "艺术",
            imageUrl: "https://picsum.photos/299/324?random=88",
            metadata: ["版画", "传统", "典雅"]
        ),
        SampleDataItem(
            id: 89,
            title: "梅花傲雪 69",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "植物",
            imageUrl: "https://picsum.photos/237/327?random=89",
            metadata: ["梅花", "傲雪", "寒冬"]
        ),
        SampleDataItem(
            id: 90,
            title: "粤式点心 70",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "美食",
            imageUrl: "https://picsum.photos/310/161?random=90",
            metadata: ["粤式", "点心", "茶点"]
        ),
        SampleDataItem(
            id: 91,
            title: "5G通信 71",
            subtitle: "清新自然",
            type: "科技",
            imageUrl: "https://picsum.photos/345/173?random=91",
            metadata: ["5G", "通信", "革命"]
        ),
        SampleDataItem(
            id: 92,
            title: "摄影作品 72",
            subtitle: "户外运动不仅能够锻炼身体，更能让人在大自然中释放压力，感受生命的活力，体验与自然和谐共处的美妙时光。",
            type: "艺术",
            imageUrl: "https://picsum.photos/247/312?random=92",
            metadata: ["摄影", "黑白", "光影"]
        ),
        SampleDataItem(
            id: 93,
            title: "粤式点心 73",
            subtitle: "植物是地球生态系统中不可或缺的重要组成部分，它们不仅美化环境，净化空气，更为人类提供了丰富的资源和精神寄托。",
            type: "美食",
            imageUrl: "https://picsum.photos/321/284?random=93",
            metadata: ["粤式", "点心", "茶点"]
        ),
        SampleDataItem(
            id: 94,
            title: "现代装置 74",
            subtitle: "动物世界充满了神奇与美妙，每一种生物都有其独特的生存智慧和生命魅力，它们与人类共同构成了这个多彩的地球家园。",
            type: "艺术",
            imageUrl: "https://picsum.photos/352/218?random=94",
            metadata: ["装置", "前卫", "空间"]
        ),
        SampleDataItem(
            id: 95,
            title: "野外露营 75",
            subtitle: "科技前沿",
            type: "户外",
            imageUrl: "https://picsum.photos/316/256?random=95",
            metadata: ["露营", "篝火", "星空"]
        ),
        SampleDataItem(
            id: 96,
            title: "版画印刷 76",
            subtitle: "和谐的搭配创造出完美的效果",
            type: "艺术",
            imageUrl: "https://picsum.photos/247/329?random=96",
            metadata: ["版画", "传统", "典雅"]
        ),
        SampleDataItem(
            id: 97,
            title: "雪山日出 77",
            subtitle: "创意无限",
            type: "风景",
            imageUrl: "https://picsum.photos/245/445?random=97",
            metadata: ["雪山", "日出", "壮美"]
        ),
        SampleDataItem(
            id: 98,
            title: "5G通信 78",
            subtitle: "植物生机",
            type: "科技",
            imageUrl: "https://picsum.photos/299/348?random=98",
            metadata: ["5G", "通信", "革命"]
        ),
        SampleDataItem(
            id: 99,
            title: "传统民居 79",
            subtitle: "植物是地球生态系统中不可或缺的重要组成部分，它们不仅美化环境，净化空气，更为人类提供了丰富的资源和精神寄托。",
            type: "建筑",
            imageUrl: "https://picsum.photos/338/301?random=99",
            metadata: ["传统", "民居", "历史"]
        ),
        SampleDataItem(
            id: 100,
            title: "松树苍劲 80",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "植物",
            imageUrl: "https://picsum.photos/256/309?random=100",
            metadata: ["松树", "苍劲", "生命力"]
        ),
        SampleDataItem(
            id: 101,
            title: "攀岩运动 81",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "户外",
            imageUrl: "https://picsum.photos/303/236?random=101",
            metadata: ["攀岩", "岩壁", "勇气"]
        ),
        SampleDataItem(
            id: 102,
            title: "人工智能 82",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "科技",
            imageUrl: "https://picsum.photos/304/263?random=102",
            metadata: ["人工智能", "技术", "便利"]
        ),
        SampleDataItem(
            id: 103,
            title: "野外露营 83",
            subtitle: "现代科技的飞速发展正在深刻地改变着我们的生活方式，从日常的衣食住行到工作学习，科技的力量让一切变得更加便捷高效。",
            type: "户外",
            imageUrl: "https://picsum.photos/339/267?random=103",
            metadata: ["露营", "篝火", "星空"]
        ),
        SampleDataItem(
            id: 104,
            title: "瀑布飞流 84",
            subtitle: "户外运动不仅能够锻炼身体，更能让人在大自然中释放压力，感受生命的活力，体验与自然和谐共处的美妙时光。",
            type: "风景",
            imageUrl: "https://picsum.photos/368/188?random=104",
            metadata: ["瀑布", "飞流", "水花"]
        ),
        SampleDataItem(
            id: 105,
            title: "现代办公楼 85",
            subtitle: "和谐之美",
            type: "建筑",
            imageUrl: "https://picsum.photos/244/189?random=105",
            metadata: ["现代", "办公楼", "都市"]
        ),
        SampleDataItem(
            id: 106,
            title: "机器人技术 86",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "科技",
            imageUrl: "https://picsum.photos/253/338?random=106",
            metadata: ["机器人", "智能", "服务"]
        ),
        SampleDataItem(
            id: 107,
            title: "古代宫殿 87",
            subtitle: "美味佳肴",
            type: "建筑",
            imageUrl: "https://picsum.photos/334/260?random=107",
            metadata: ["古代", "宫殿", "工艺"]
        ),
        SampleDataItem(
            id: 108,
            title: "攀岩运动 88",
            subtitle: "在这个充满诗意的季节里，大自然展现出她最美丽的一面，每一处风景都如画卷般令人陶醉，让我们在忙碌的生活中找到片刻的宁静与美好。",
            type: "户外",
            imageUrl: "https://picsum.photos/220/224?random=108",
            metadata: ["攀岩", "岩壁", "勇气"]
        ),
        SampleDataItem(
            id: 109,
            title: "野外露营 89",
            subtitle: "精致的设计展现了独特的艺术风格",
            type: "户外",
            imageUrl: "https://picsum.photos/322/222?random=109",
            metadata: ["露营", "篝火", "星空"]
        ),
        SampleDataItem(
            id: 110,
            title: "森林探险 90",
            subtitle: "宁静致远",
            type: "户外",
            imageUrl: "https://picsum.photos/247/182?random=110",
            metadata: ["森林", "探险", "神秘"]
        ),
        SampleDataItem(
            id: 111,
            title: "玫瑰花园 91",
            subtitle: "精致的设计展现了独特的艺术风格",
            type: "植物",
            imageUrl: "https://picsum.photos/241/370?random=111",
            metadata: ["玫瑰", "花园", "花香"]
        ),
        SampleDataItem(
            id: 112,
            title: "樱花盛开 92",
            subtitle: "现代科技的飞速发展正在深刻地改变着我们的生活方式，从日常的衣食住行到工作学习，科技的力量让一切变得更加便捷高效。",
            type: "植物",
            imageUrl: "https://picsum.photos/368/274?random=112",
            metadata: ["樱花", "盛开", "春日"]
        ),
        SampleDataItem(
            id: 113,
            title: "湖光山色 93",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "风景",
            imageUrl: "https://picsum.photos/356/406?random=113",
            metadata: ["湖泊", "山色", "宁静"]
        ),
        SampleDataItem(
            id: 114,
            title: "版画印刷 94",
            subtitle: "绿色植物为世界增添了无限生机",
            type: "艺术",
            imageUrl: "https://picsum.photos/247/319?random=114",
            metadata: ["版画", "传统", "典雅"]
        ),
        SampleDataItem(
            id: 115,
            title: "荷花池塘 95",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "植物",
            imageUrl: "https://picsum.photos/245/234?random=115",
            metadata: ["荷花", "池塘", "清雅"]
        ),
        SampleDataItem(
            id: 116,
            title: "现代装置 96",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "艺术",
            imageUrl: "https://picsum.photos/349/399?random=116",
            metadata: ["装置", "前卫", "空间"]
        ),
        SampleDataItem(
            id: 117,
            title: "传统民居 97",
            subtitle: "清新自然",
            type: "建筑",
            imageUrl: "https://picsum.photos/308/207?random=117",
            metadata: ["传统", "民居", "历史"]
        ),
        SampleDataItem(
            id: 118,
            title: "人工智能 98",
            subtitle: "在这个充满诗意的季节里，大自然展现出她最美丽的一面，每一处风景都如画卷般令人陶醉，让我们在忙碌的生活中找到片刻的宁静与美好。",
            type: "科技",
            imageUrl: "https://picsum.photos/351/418?random=118",
            metadata: ["人工智能", "技术", "便利"]
        ),
        SampleDataItem(
            id: 119,
            title: "荷花池塘 99",
            subtitle: "建筑奇观",
            type: "植物",
            imageUrl: "https://picsum.photos/335/200?random=119",
            metadata: ["荷花", "池塘", "清雅"]
        ),
        SampleDataItem(
            id: 120,
            title: "登山征途 100",
            subtitle: "建筑是人类文明的重要载体，每一座建筑都承载着特定的历史文化内涵，展现着不同时代的审美理念和技术水平。",
            type: "户外",
            imageUrl: "https://picsum.photos/331/311?random=120",
            metadata: ["登山", "征途", "挑战"]
        ),
        SampleDataItem(
            id: 121,
            title: "雪山日出 101",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "风景",
            imageUrl: "https://picsum.photos/292/251?random=121",
            metadata: ["雪山", "日出", "壮美"]
        ),
        SampleDataItem(
            id: 122,
            title: "韩式烤肉 102",
            subtitle: "植物生机",
            type: "美食",
            imageUrl: "https://picsum.photos/284/189?random=122",
            metadata: ["韩式", "烤肉", "炭火"]
        ),
        SampleDataItem(
            id: 123,
            title: "雪山日出 103",
            subtitle: "宁静的环境让心灵得到放松",
            type: "风景",
            imageUrl: "https://picsum.photos/354/281?random=123",
            metadata: ["雪山", "日出", "壮美"]
        ),
        SampleDataItem(
            id: 124,
            title: "海边冲浪 104",
            subtitle: "和谐的搭配创造出完美的效果",
            type: "户外",
            imageUrl: "https://picsum.photos/313/307?random=124",
            metadata: ["冲浪", "海浪", "搏击"]
        ),
        SampleDataItem(
            id: 125,
            title: "法式牛排 105",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "美食",
            imageUrl: "https://picsum.photos/240/450?random=125",
            metadata: ["法式", "牛排", "红酒"]
        ),
        SampleDataItem(
            id: 126,
            title: "狮子王者 106",
            subtitle: "匠心独运",
            type: "动物",
            imageUrl: "https://picsum.photos/334/408?random=126",
            metadata: ["狮子", "草原", "王者"]
        ),
        SampleDataItem(
            id: 127,
            title: "攀岩运动 107",
            subtitle: "简约之美",
            type: "户外",
            imageUrl: "https://picsum.photos/340/407?random=127",
            metadata: ["攀岩", "岩壁", "勇气"]
        ),
        SampleDataItem(
            id: 128,
            title: "古代宫殿 108",
            subtitle: "诗意生活",
            type: "建筑",
            imageUrl: "https://picsum.photos/366/246?random=128",
            metadata: ["古代", "宫殿", "工艺"]
        ),
        SampleDataItem(
            id: 129,
            title: "量子计算 109",
            subtitle: "浪漫情怀",
            type: "科技",
            imageUrl: "https://picsum.photos/379/344?random=129",
            metadata: ["量子", "计算", "提升"]
        ),
        SampleDataItem(
            id: 130,
            title: "攀岩运动 110",
            subtitle: "丰富的色彩构成了美丽的画面",
            type: "户外",
            imageUrl: "https://picsum.photos/367/438?random=130",
            metadata: ["攀岩", "岩壁", "勇气"]
        ),
        SampleDataItem(
            id: 131,
            title: "登山征途 111",
            subtitle: "户外运动不仅能够锻炼身体，更能让人在大自然中释放压力，感受生命的活力，体验与自然和谐共处的美妙时光。",
            type: "户外",
            imageUrl: "https://picsum.photos/248/388?random=131",
            metadata: ["登山", "征途", "挑战"]
        ),
        SampleDataItem(
            id: 132,
            title: "松鼠觅食 112",
            subtitle: "和谐之美",
            type: "动物",
            imageUrl: "https://picsum.photos/241/379?random=132",
            metadata: ["松鼠", "觅食", "坚果"]
        ),
        SampleDataItem(
            id: 133,
            title: "野外露营 113",
            subtitle: "可爱的动物们展现着生命的活力",
            type: "户外",
            imageUrl: "https://picsum.photos/250/205?random=133",
            metadata: ["露营", "篝火", "星空"]
        ),
        SampleDataItem(
            id: 134,
            title: "海岸礁石 114",
            subtitle: "绿色植物为世界增添了无限生机",
            type: "风景",
            imageUrl: "https://picsum.photos/325/257?random=134",
            metadata: ["海岸", "礁石", "海鸟"]
        ),
        SampleDataItem(
            id: 135,
            title: "陶瓷艺术 115",
            subtitle: "时尚潮流",
            type: "艺术",
            imageUrl: "https://picsum.photos/358/243?random=135",
            metadata: ["陶瓷", "造型", "工艺"]
        ),
        SampleDataItem(
            id: 136,
            title: "蝴蝶花间 116",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "动物",
            imageUrl: "https://picsum.photos/326/277?random=136",
            metadata: ["蝴蝶", "花间", "翩翩"]
        ),
        SampleDataItem(
            id: 137,
            title: "日式寿司 117",
            subtitle: "植物是地球生态系统中不可或缺的重要组成部分，它们不仅美化环境，净化空气，更为人类提供了丰富的资源和精神寄托。",
            type: "美食",
            imageUrl: "https://picsum.photos/333/199?random=137",
            metadata: ["日式", "寿司", "生鱼片"]
        ),
        SampleDataItem(
            id: 138,
            title: "滑雪运动 118",
            subtitle: "传统文化",
            type: "户外",
            imageUrl: "https://picsum.photos/302/445?random=138",
            metadata: ["滑雪", "山坡", "激情"]
        ),
        SampleDataItem(
            id: 139,
            title: "机器人技术 119",
            subtitle: "现代科技的飞速发展正在深刻地改变着我们的生活方式，从日常的衣食住行到工作学习，科技的力量让一切变得更加便捷高效。",
            type: "科技",
            imageUrl: "https://picsum.photos/282/182?random=139",
            metadata: ["机器人", "智能", "服务"]
        ),
        SampleDataItem(
            id: 140,
            title: "雪山日出 120",
            subtitle: "建筑奇观",
            type: "风景",
            imageUrl: "https://picsum.photos/379/284?random=140",
            metadata: ["雪山", "日出", "壮美"]
        ),
        SampleDataItem(
            id: 141,
            title: "海龟游泳 121",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "动物",
            imageUrl: "https://picsum.photos/292/234?random=141",
            metadata: ["海龟", "海水", "智慧"]
        ),
        SampleDataItem(
            id: 142,
            title: "古代宫殿 122",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "建筑",
            imageUrl: "https://picsum.photos/243/275?random=142",
            metadata: ["古代", "宫殿", "工艺"]
        ),
        SampleDataItem(
            id: 143,
            title: "古塔建筑 123",
            subtitle: "自然风光",
            type: "建筑",
            imageUrl: "https://picsum.photos/375/418?random=143",
            metadata: ["古塔", "千年", "文化"]
        ),
        SampleDataItem(
            id: 144,
            title: "湖光山色 124",
            subtitle: "传统文化",
            type: "风景",
            imageUrl: "https://picsum.photos/266/450?random=144",
            metadata: ["湖泊", "山色", "宁静"]
        ),
        SampleDataItem(
            id: 145,
            title: "小鹿斑比 125",
            subtitle: "充满活力的场景令人心情愉悦",
            type: "动物",
            imageUrl: "https://picsum.photos/379/333?random=145",
            metadata: ["小鹿", "森林", "溪边"]
        ),
        SampleDataItem(
            id: 146,
            title: "海边冲浪 126",
            subtitle: "精致的设计展现了独特的艺术风格",
            type: "户外",
            imageUrl: "https://picsum.photos/328/342?random=146",
            metadata: ["冲浪", "海浪", "搏击"]
        ),
        SampleDataItem(
            id: 147,
            title: "海龟游泳 127",
            subtitle: "诗意生活",
            type: "动物",
            imageUrl: "https://picsum.photos/312/436?random=147",
            metadata: ["海龟", "海水", "智慧"]
        ),
        SampleDataItem(
            id: 148,
            title: "薰衣草田 128",
            subtitle: "在这个充满诗意的季节里，大自然展现出她最美丽的一面，每一处风景都如画卷般令人陶醉，让我们在忙碌的生活中找到片刻的宁静与美好。",
            type: "植物",
            imageUrl: "https://picsum.photos/238/376?random=148",
            metadata: ["薰衣草", "紫色", "香气"]
        ),
        SampleDataItem(
            id: 149,
            title: "泰式咖喱 129",
            subtitle: "宁静的环境让心灵得到放松",
            type: "美食",
            imageUrl: "https://picsum.photos/354/358?random=149",
            metadata: ["泰式", "咖喱", "椰浆"]
        ),
        SampleDataItem(
            id: 150,
            title: "意式披萨 130",
            subtitle: "建筑艺术体现了人类的智慧结晶",
            type: "美食",
            imageUrl: "https://picsum.photos/246/407?random=150",
            metadata: ["意式", "披萨", "奶酪"]
        ),
        SampleDataItem(
            id: 151,
            title: "园林亭台 131",
            subtitle: "美味佳肴",
            type: "建筑",
            imageUrl: "https://picsum.photos/369/376?random=151",
            metadata: ["园林", "亭台", "造园"]
        ),
        SampleDataItem(
            id: 152,
            title: "韩式烤肉 132",
            subtitle: "现代科技改变着我们的生活方式",
            type: "美食",
            imageUrl: "https://picsum.photos/337/214?random=152",
            metadata: ["韩式", "烤肉", "炭火"]
        ),
        SampleDataItem(
            id: 153,
            title: "生物技术 133",
            subtitle: "可爱的动物们展现着生命的活力",
            type: "科技",
            imageUrl: "https://picsum.photos/371/249?random=153",
            metadata: ["生物", "医学", "治疗"]
        ),
        SampleDataItem(
            id: 154,
            title: "电动汽车 134",
            subtitle: "典雅风范",
            type: "科技",
            imageUrl: "https://picsum.photos/253/255?random=154",
            metadata: ["电动", "汽车", "环保"]
        ),
        SampleDataItem(
            id: 155,
            title: "小鹿斑比 135",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "动物",
            imageUrl: "https://picsum.photos/225/421?random=155",
            metadata: ["小鹿", "森林", "溪边"]
        ),
        SampleDataItem(
            id: 156,
            title: "漂流冒险 136",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "户外",
            imageUrl: "https://picsum.photos/253/232?random=156",
            metadata: ["漂流", "河流", "刺激"]
        ),
        SampleDataItem(
            id: 157,
            title: "海岸礁石 137",
            subtitle: "匠心独运",
            type: "风景",
            imageUrl: "https://picsum.photos/263/239?random=157",
            metadata: ["海岸", "礁石", "海鸟"]
        ),
        SampleDataItem(
            id: 158,
            title: "川菜麻辣锅 138",
            subtitle: "丰富的色彩构成了美丽的画面",
            type: "美食",
            imageUrl: "https://picsum.photos/302/268?random=158",
            metadata: ["川菜", "麻辣", "香辣"]
        ),
        SampleDataItem(
            id: 159,
            title: "蝴蝶花间 139",
            subtitle: "现代科技改变着我们的生活方式",
            type: "动物",
            imageUrl: "https://picsum.photos/325/406?random=159",
            metadata: ["蝴蝶", "花间", "翩翩"]
        ),
        SampleDataItem(
            id: 160,
            title: "电动汽车 140",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "科技",
            imageUrl: "https://picsum.photos/333/413?random=160",
            metadata: ["电动", "汽车", "环保"]
        ),
        SampleDataItem(
            id: 161,
            title: "樱花盛开 141",
            subtitle: "宁静的环境让心灵得到放松",
            type: "植物",
            imageUrl: "https://picsum.photos/262/286?random=161",
            metadata: ["樱花", "盛开", "春日"]
        ),
        SampleDataItem(
            id: 162,
            title: "荷花池塘 142",
            subtitle: "建筑奇观",
            type: "植物",
            imageUrl: "https://picsum.photos/288/349?random=162",
            metadata: ["荷花", "池塘", "清雅"]
        ),
        SampleDataItem(
            id: 163,
            title: "5G通信 143",
            subtitle: "充满活力的场景令人心情愉悦",
            type: "科技",
            imageUrl: "https://picsum.photos/320/351?random=163",
            metadata: ["5G", "通信", "革命"]
        ),
        SampleDataItem(
            id: 164,
            title: "熊猫宝宝 144",
            subtitle: "在这个充满诗意的季节里，大自然展现出她最美丽的一面，每一处风景都如画卷般令人陶醉，让我们在忙碌的生活中找到片刻的宁静与美好。",
            type: "动物",
            imageUrl: "https://picsum.photos/341/313?random=164",
            metadata: ["熊猫", "宝宝", "竹林"]
        ),
        SampleDataItem(
            id: 165,
            title: "荷花池塘 145",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "植物",
            imageUrl: "https://picsum.photos/369/164?random=165",
            metadata: ["荷花", "池塘", "清雅"]
        ),
        SampleDataItem(
            id: 166,
            title: "瀑布飞流 146",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "风景",
            imageUrl: "https://picsum.photos/279/208?random=166",
            metadata: ["瀑布", "飞流", "水花"]
        ),
        SampleDataItem(
            id: 167,
            title: "生物技术 147",
            subtitle: "美食不仅仅是味觉的享受，更是文化的传承和情感的表达，每一道精心制作的菜肴都承载着厨师的匠心独运和对美好生活的向往。",
            type: "科技",
            imageUrl: "https://picsum.photos/247/328?random=167",
            metadata: ["生物", "医学", "治疗"]
        ),
        SampleDataItem(
            id: 168,
            title: "仙人掌花 148",
            subtitle: "温馨时光",
            type: "植物",
            imageUrl: "https://picsum.photos/332/450?random=168",
            metadata: ["仙人掌", "沙漠", "奇迹"]
        ),
        SampleDataItem(
            id: 169,
            title: "现代装置 149",
            subtitle: "在这个美好的时刻，感受大自然的魅力",
            type: "艺术",
            imageUrl: "https://picsum.photos/288/317?random=169",
            metadata: ["装置", "前卫", "空间"]
        ),
        SampleDataItem(
            id: 170,
            title: "现代桥梁 150",
            subtitle: "时尚潮流",
            type: "建筑",
            imageUrl: "https://picsum.photos/230/213?random=170",
            metadata: ["现代", "桥梁", "工程"]
        ),
        SampleDataItem(
            id: 171,
            title: "沙漠驼队 151",
            subtitle: "建筑奇观",
            type: "风景",
            imageUrl: "https://picsum.photos/261/347?random=171",
            metadata: ["沙漠", "驼队", "足迹"]
        ),
        SampleDataItem(
            id: 172,
            title: "竹子青翠 152",
            subtitle: "户外探险",
            type: "植物",
            imageUrl: "https://picsum.photos/318/246?random=172",
            metadata: ["竹子", "青翠", "坚韧"]
        ),
        SampleDataItem(
            id: 173,
            title: "现代桥梁 153",
            subtitle: "典雅风范",
            type: "建筑",
            imageUrl: "https://picsum.photos/342/255?random=173",
            metadata: ["现代", "桥梁", "工程"]
        ),
        SampleDataItem(
            id: 174,
            title: "湖光山色 154",
            subtitle: "科技前沿",
            type: "风景",
            imageUrl: "https://picsum.photos/230/398?random=174",
            metadata: ["湖泊", "山色", "宁静"]
        ),
        SampleDataItem(
            id: 175,
            title: "川菜麻辣锅 155",
            subtitle: "户外运动让人感受到自由的快乐",
            type: "美食",
            imageUrl: "https://picsum.photos/372/176?random=175",
            metadata: ["川菜", "麻辣", "香辣"]
        ),
        SampleDataItem(
            id: 176,
            title: "松树苍劲 156",
            subtitle: "可爱的动物们展现着生命的活力",
            type: "植物",
            imageUrl: "https://picsum.photos/280/160?random=176",
            metadata: ["松树", "苍劲", "生命力"]
        ),
        SampleDataItem(
            id: 177,
            title: "电动汽车 157",
            subtitle: "丰富的色彩构成了美丽的画面",
            type: "科技",
            imageUrl: "https://picsum.photos/220/172?random=177",
            metadata: ["电动", "汽车", "环保"]
        ),
        SampleDataItem(
            id: 178,
            title: "沙漠驼队 158",
            subtitle: "科技前沿",
            type: "风景",
            imageUrl: "https://picsum.photos/249/326?random=178",
            metadata: ["沙漠", "驼队", "足迹"]
        ),
        SampleDataItem(
            id: 179,
            title: "滑雪运动 159",
            subtitle: "户外运动让人感受到自由的快乐",
            type: "户外",
            imageUrl: "https://picsum.photos/230/388?random=179",
            metadata: ["滑雪", "山坡", "激情"]
        ),
        SampleDataItem(
            id: 180,
            title: "雪山日出 160",
            subtitle: "创新设计引领着时代的发展潮流",
            type: "风景",
            imageUrl: "https://picsum.photos/372/357?random=180",
            metadata: ["雪山", "日出", "壮美"]
        ),
        SampleDataItem(
            id: 181,
            title: "传统民居 161",
            subtitle: "植物是地球生态系统中不可或缺的重要组成部分，它们不仅美化环境，净化空气，更为人类提供了丰富的资源和精神寄托。",
            type: "建筑",
            imageUrl: "https://picsum.photos/352/418?random=181",
            metadata: ["传统", "民居", "历史"]
        ),
        SampleDataItem(
            id: 182,
            title: "草原牧歌 162",
            subtitle: "丰富的色彩构成了美丽的画面",
            type: "风景",
            imageUrl: "https://picsum.photos/358/443?random=182",
            metadata: ["草原", "牧歌", "牛羊"]
        ),
        SampleDataItem(
            id: 183,
            title: "陶瓷艺术 163",
            subtitle: "现代科技的飞速发展正在深刻地改变着我们的生活方式，从日常的衣食住行到工作学习，科技的力量让一切变得更加便捷高效。",
            type: "艺术",
            imageUrl: "https://picsum.photos/338/231?random=183",
            metadata: ["陶瓷", "造型", "工艺"]
        ),
        SampleDataItem(
            id: 184,
            title: "湖光山色 164",
            subtitle: "建筑奇观",
            type: "风景",
            imageUrl: "https://picsum.photos/278/353?random=184",
            metadata: ["湖泊", "山色", "宁静"]
        ),
        SampleDataItem(
            id: 185,
            title: "雄鹰翱翔 165",
            subtitle: "建筑是人类文明的重要载体，每一座建筑都承载着特定的历史文化内涵，展现着不同时代的审美理念和技术水平。",
            type: "动物",
            imageUrl: "https://picsum.photos/375/227?random=185",
            metadata: ["雄鹰", "翱翔", "王者"]
        ),
        SampleDataItem(
            id: 186,
            title: "古塔建筑 166",
            subtitle: "精致工艺",
            type: "建筑",
            imageUrl: "https://picsum.photos/289/456?random=186",
            metadata: ["古塔", "千年", "文化"]
        ),
        SampleDataItem(
            id: 187,
            title: "漂流冒险 167",
            subtitle: "生机勃勃",
            type: "户外",
            imageUrl: "https://picsum.photos/278/314?random=187",
            metadata: ["漂流", "河流", "刺激"]
        ),
        SampleDataItem(
            id: 188,
            title: "荷花池塘 168",
            subtitle: "宁静的环境让心灵得到放松",
            type: "植物",
            imageUrl: "https://picsum.photos/252/288?random=188",
            metadata: ["荷花", "池塘", "清雅"]
        ),
        SampleDataItem(
            id: 189,
            title: "仙人掌花 169",
            subtitle: "户外运动不仅能够锻炼身体，更能让人在大自然中释放压力，感受生命的活力，体验与自然和谐共处的美妙时光。",
            type: "植物",
            imageUrl: "https://picsum.photos/260/204?random=189",
            metadata: ["仙人掌", "沙漠", "奇迹"]
        ),
        SampleDataItem(
            id: 190,
            title: "量子计算 170",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "科技",
            imageUrl: "https://picsum.photos/227/368?random=190",
            metadata: ["量子", "计算", "提升"]
        ),
        SampleDataItem(
            id: 191,
            title: "传统民居 171",
            subtitle: "生机勃勃",
            type: "建筑",
            imageUrl: "https://picsum.photos/340/265?random=191",
            metadata: ["传统", "民居", "历史"]
        ),
        SampleDataItem(
            id: 192,
            title: "古代宫殿 172",
            subtitle: "可爱的动物们展现着生命的活力",
            type: "建筑",
            imageUrl: "https://picsum.photos/260/296?random=192",
            metadata: ["古代", "宫殿", "工艺"]
        ),
        SampleDataItem(
            id: 193,
            title: "太空探索 173",
            subtitle: "植物是地球生态系统中不可或缺的重要组成部分，它们不仅美化环境，净化空气，更为人类提供了丰富的资源和精神寄托。",
            type: "科技",
            imageUrl: "https://picsum.photos/277/287?random=193",
            metadata: ["太空", "探索", "火箭"]
        ),
        SampleDataItem(
            id: 194,
            title: "瀑布飞流 174",
            subtitle: "温馨时光",
            type: "风景",
            imageUrl: "https://picsum.photos/355/318?random=194",
            metadata: ["瀑布", "飞流", "水花"]
        ),
        SampleDataItem(
            id: 195,
            title: "机器人技术 175",
            subtitle: "现代科技改变着我们的生活方式",
            type: "科技",
            imageUrl: "https://picsum.photos/290/292?random=195",
            metadata: ["机器人", "智能", "服务"]
        ),
        SampleDataItem(
            id: 196,
            title: "古代宫殿 176",
            subtitle: "美味的食物带来味蕾上的享受",
            type: "建筑",
            imageUrl: "https://picsum.photos/317/409?random=196",
            metadata: ["古代", "宫殿", "工艺"]
        ),
        SampleDataItem(
            id: 197,
            title: "樱花盛开 177",
            subtitle: "自然风光",
            type: "植物",
            imageUrl: "https://picsum.photos/313/430?random=197",
            metadata: ["樱花", "盛开", "春日"]
        ),
        SampleDataItem(
            id: 198,
            title: "瀑布飞流 178",
            subtitle: "精致工艺",
            type: "风景",
            imageUrl: "https://picsum.photos/224/163?random=198",
            metadata: ["瀑布", "飞流", "水花"]
        ),
        SampleDataItem(
            id: 199,
            title: "现代装置 179",
            subtitle: "传统工艺承载着深厚的文化底蕴",
            type: "艺术",
            imageUrl: "https://picsum.photos/314/342?random=199",
            metadata: ["装置", "前卫", "空间"]
        ),
        SampleDataItem(
            id: 200,
            title: "滑雪运动 180",
            subtitle: "简约之美",
            type: "户外",
            imageUrl: "https://picsum.photos/256/376?random=200",
            metadata: ["滑雪", "山坡", "激情"]
        )
    ]
    
    /// 获取所有测试数据
    public static func getAllTestData() -> [SampleDataItem] {
        return testItems
    }
    
    /// 按类型分组的测试数据
    public static func getTestDataByType() -> [String: [SampleDataItem]] {
        return Dictionary(grouping: testItems, by: { $0.type })
    }
    
    /// 获取指定数量的测试数据
    public static func getTestData(count: Int) -> [SampleDataItem] {
        return Array(testItems.prefix(count))
    }
    
    /// 获取随机测试数据
    public static func getRandomTestData(count: Int) -> [SampleDataItem] {
        return Array(testItems.shuffled().prefix(count))
    }
    
    /// 按subtitle长度分类的测试数据
    public static func getTestDataBySubtitleLength() -> (short: [SampleDataItem], medium: [SampleDataItem], long: [SampleDataItem]) {
        let short = testItems.filter { $0.subtitle.count <= 15 }
        let medium = testItems.filter { $0.subtitle.count > 15 && $0.subtitle.count <= 45 }
        let long = testItems.filter { $0.subtitle.count > 45 }
        return (short: short, medium: medium, long: long)
    }
}
