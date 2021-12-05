export class Review{
    /**
     *
     */
    constructor(
        public id: number,
        public username: string,
        public title: string,
        public review: string,
        public rating: number,
        public points: number,
        ) 
    {
    }
   
}
export const reviews = [
    new Review( 0, "Anitaaa43", "Nagyszerű!!!", "Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!", 5, 6 ),
    new Review( 1, "kmarika1234", "Csinos nyaklánc a kollekciómba", "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", 4, 3 ),
    new Review( 2, "kmarika1234", "Szép darab", "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", 4, 2 )
]