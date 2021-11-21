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

class User {
    name: string;
    follows?: Number;
    followers?: Number;

    constructor() {
        this.name = "";
        this.followers = undefined;
    }
}