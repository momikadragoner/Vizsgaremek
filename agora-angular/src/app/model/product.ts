import { Review, reviews } from "./review";

export class Product{
    /**
     *
     */
    constructor(
        public id: number,
        public name: string,
        public seller: string,
        public price: number,
        public discountAvailable: boolean,
        public inventory: number,
        public delivery: string,
        public category: string,
        public tags: string[],
        public materials: string[],
        public imgUrl: string,
        public isPublic: boolean,
        public discount?: number,
        public rating?: number,
        public reviews?: Review[],
        ) 
    {
    }
   
}

export const productListShort = [
    new Product( 1, "Gyöngy nyakék", "Kiss Márta", 12599, false, 12, "Azonnal szállítható", "Ékszer", ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["arany", "ásvány"], "assets/item2.jpg", true),
    new Product( 2, "Arany lánc", "Nagy Erzsébet", 18599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item1.jpg", true),
    new Product( 3, "Ásvány medál ékszer", "Széles Lajos", 11999, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item3.jfif", true),
    new Product( 4, "Arany és kristály nyaklánc", "Közepes Borbála", 19599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item4.jpg", true),
];

export const productListLong = [
    new Product( 1, "Gyöngy nyakék", "Kiss Márta", 12599, false, 12, "Azonnal szállítható", "Ékszer", ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["arany", "ásvány"], "assets/item2.jpg", true),
    new Product( 2, "Arany lánc", "Nagy Erzsébet", 18599, false, 8, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item1.jpg", true),
    new Product( 3, "Ásvány medál ékszer", "Széles Lajos", 11999, false, 7, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item3.jfif", true),
    new Product( 4, "Arany és kristály nyaklánc", "Közepes Borbála", 19599, false, 5, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item4.jpg", true),
    new Product( 5, "Őszibarack befőtt", "Kiss Márta", 2599, false, 23, "Azonnal szállítható", "Élelmiszer", ["Vegán", "Bio", "Helyben termesztett"], ["őszibarack", "víz", "cukor"], "assets/item5.jfif", true),
    new Product( 6, "Egres befőtt", "Szekszárdi Katalin", 2799, false, 17, "Azonnal szállítható", "Élelmiszer", ["Vegán", "Bio", "Helyben termesztett"], ["őszibarack", "víz", "cukor"], "assets/item6.jpg", true),
    new Product( 7, "Diós és lekváros leveles kiflik", "Szekszárdi Katalin", 1999, false, 17, "Azonnal szállítható", "Élelmiszer", ["Bio", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["tej", "tojás", "cukor", "liszt"], "assets/item7.jpg", true),
    new Product( 8, "Túrós-fahéjas hajtogatós ", "Szekszárdi Katalin", 1999, false, 17, "Azonnal szállítható", "Élelmiszer", ["Bio", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["túró", "fahéj", "cukor", "liszt"], "assets/item8.jpg", true),
];

export const productDetailed = new Product(
    1, "Gyöngy nyakék", 
    "Kiss Márta", 
    12599, false, 12, 
    "Azonnal szállítható", 
    "Ékszer", 
    ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"], 
    ["arany", "ásvány"], 
    "assets/item2.jpg", 
    true, undefined, 
    4.7, 
    reviews
);

export const tags = [
    "Környezetbarát",
    "Kézzel készült",
    "Etikusan beszerzett alapanyagok",
    "Vegán",
    "Vegetáriánus",
    "Organikus",
    "Bio",
    "Helyben termesztett",
]