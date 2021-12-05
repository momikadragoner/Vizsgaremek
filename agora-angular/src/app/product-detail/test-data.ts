import { EmailValidator } from "@angular/forms";

export const productDetail =
{
    name: "Csodálatos arany nyaklánc medál",
    price: "6 499",
    inventory: "4",
    imgUrl: ["assets/item1.jpg", "assets/item2.jpg", "assets/item4.jpg"],
    category: "Ékszer",
    description: "Lorem ipsum dolor sit amet consectetur adipisicing elit. Tempore, quo voluptates nemo dolores at modi ipsam fuga odio architecto beatae aliquid molestiae enim qui obcaecati doloribus. Ex saepe voluptatem magnam!",
    material: ["ásvány", "arany"],
    delivery: "Azonnal szállítható",
    tags: ["Kézzel készült", "Etikusan beszerzett alapanyagok", "Környezetbarát"],
    seller: "Nagy Erzsébet",
    sellerDescription: "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎",
    takesCustomOrders: true,
    rating: 4.7,
    reviews: [
        { id: 0, username: "Anitaaa43", title: "Nagyszerű!!!", review: "Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!", rating: "5", points: 6 },
        { id: 1, username: "kmarika1234", title: "Csinos nyaklánc a kollekciómba", review: "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", rating: "4", points: 3 },
        { id: 2, username: "kmarika1234", title: "Szép darab", review: "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", rating: "4", points: 2 }
    ]
}

export const products = [
    { productName: "Gyöngy nyakék", sellerName: "Kiss Márta", price: "12 599", imgUrl: "assets/item2.jpg" },
    { productName: "Arany lánc", sellerName: "Nagy Erzsébet", price: "18 999", imgUrl: "assets/item1.jpg" },
    { productName: "Ásvány medál ékszer", sellerName: "Széles Lajos", price: "11 999", imgUrl: "assets/item3.jfif" },
    { productName: "Arany és kristály nyaklánc", sellerName: "Közepes Borbála", price: "19 599", imgUrl: "assets/item4.jpg" }
];

export const myProducts = [
    { productName: "Gyöngy nyakék", sellerName: "Kiss Márta", price: "12 599", imgUrl: "assets/item2.jpg", public: false },
    { productName: "Arany lánc", sellerName: "Nagy Erzsébet", price: "18 999", imgUrl: "assets/item1.jpg", public: true },
    { productName: "Ásvány medál ékszer", sellerName: "Széles Lajos", price: "11 999", imgUrl: "assets/item3.jfif", public: true },
    { productName: "Arany és kristály nyaklánc", sellerName: "Közepes Borbála", price: "19 599", imgUrl: "assets/item4.jpg", public: true }
];

export const profileDetail=
    {name: "Nagy Erzsébet", email:"erzsiekszer.hu", location:"Nagybajcs", description: "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎", profileUrl:"assets/profilepic.jpg"}
;

class User {
    name: string;
    follows?: Number;
    followers?: Number;

    constructor() {
        this.name = "";
        this.followers = undefined;
    }
}

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
        public materilas: string[],
        public imgUrl: string,
        public isPublic: boolean,
        public discount?: number,
        ) 
    {
    }
   
}

export const productsClass = [
    new Product( 1, "Gyöngy nyakék", "Kiss Márta", 12599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item2.jpg", true),
    new Product( 2, "Arany lánc", "Nagy Erzsébet", 18599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item1.jpg", true),
    new Product( 3, "Ásvány medál ékszer", "Széles Lajos", 11999, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item3.jfif", true),
    new Product( 4, "Arany és kristály nyaklánc", "Közepes Borbála", 19599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], "assets/item4.jpg", true)
];