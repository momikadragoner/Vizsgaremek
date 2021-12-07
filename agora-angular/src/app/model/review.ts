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
        public publishedAt: Date
        ) 
    {
    }
   
}
export const reviews = [
    new Review( 0, "Anitaaa43", "Nagyszerű!!!", "Az unokámnak vettem szülinapjára és imádja!!!! Köszönöm!!!!!", 5, 6, new Date(2021, 10, 28) ),
    new Review( 1, "kmarika1234", "Csinos nyaklánc a kollekciómba", "Aprólékos, jól kidolgozatt nyaklánc, csak ajánlani tudom. Nekem egy picit hosszú, de a lánc hosszát meg lehet igazítani.", 4, 3, new Date(2021, 11, 6) ),
    new Review( 2, "kmarika1234", "Szép darab", "Egyszerűen imádom lorem ipsum dolor sit amet", 4, 2, new Date(2021, 11, 1) ),
]

export const ratingToArray = function(rating:number):number[]{
    let stars:number[] = [];
    for (let index = 0; index < rating; index++) {
      stars.push(index);
    }
    return stars;
  }