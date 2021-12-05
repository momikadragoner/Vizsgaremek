export class User{
    /**
     *
     */
    constructor(
        public id: number,
        public name: string,
        public follows: number,
        public followers: number,
        public email: string,
        public phone: string,
        public about: string,
        public profileImgUrl: string,
        public headerImgUrl: string,
        public registeredAt: Date,
        public isVendor: boolean,
        public isAdmin: boolean,
        public companyName?: string,
        public siteLocation?: string,
        public website?: string,
        public takesCustomOrders?: boolean,
        ) 
    {
    }
   
}

export const seller = new User( 
    1, 
    "Nagy Erzsébet", 
    16, 54, 
    "erzsi.nagy@mail.hu", 
    "301234567", 
    "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎",
    "assets/profilepic.jpg",
    "assets/header2.jpg",
    new Date(2021, 11, 2),
    true,
    false,
    undefined,
    "Nagybajcs",
    "erzsiekszer.hu",
    true 
)