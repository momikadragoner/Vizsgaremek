export class Product{
    /**
     *
     */
    constructor(
        public id: number,
        public name: string,
        public price: number,
        public discountAvailable: boolean,
        public inventory: number,
        public delivery: string,
        public category: string,
        public tags: string[],
        public materilas: string[],
        public picrureUrl: string,
        public discount?: number,
        ) 
    {

    }
   
}