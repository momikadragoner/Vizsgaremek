import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';

export interface Product {
  id: number,
  name: string,
  seller: string,
  price: number,
  discountAvailable: boolean,
  inventory: number,
  delivery: string,
  category: string,
  tags: string[],
  materials: string[],
  imgUrl: string[],
  description: string,
  isPublic: boolean,
  discount?: number,
  rating?: number,
  sellerId?: number,
}

export interface ProductShort {
  id: number,
  name: string,
  seller: string,
  price: number,
  discountAvailable: boolean,
  imgUrl: string,
  discount?: number,
}

export interface Review {
  id: number,
  username: string,
  title: string,
  review: string,
  rating: number,
  points: number,
  publishedAt: Date
}

@Injectable()
export class ProductService {

  constructor(private http: HttpClient) { }

  rootURL = '/api';

  getProduct(id:any) {
    return this.http.get<Product>(this.rootURL + '/product/' + id,)
    .pipe(
      catchError(this.handleError)
    );
  }

  getReviews() {
    return this.http.get<[Review]>(this.rootURL + '/reviews');
  }

  getProductList() {
    return this.http.get<[ProductShort]>(this.rootURL + '/product-list');
  }

  getProductListLong() {
    return this.http.get<[ProductShort]>(this.rootURL + '/product-list-long');
  }

  private handleError(error: HttpErrorResponse) {
    if (error.status === 0) {
      // A client-side or network error occurred. Handle it accordingly.
      console.error('An error occurred:', error.error);
    } else {
      // The backend returned an unsuccessful response code.
      // The response body may contain clues as to what went wrong.
      console.error(
        `Backend returned code ${error.status}, body was: `, error.error);
    }
    // Return an observable with a user-facing error message.
    return throwError(
      'Something bad happened; please try again later.');
  }

}

export class Product {
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
    public imgUrl: string[],
    public description: string,
    public isPublic: boolean,
    public discount?: number,
    public rating?: number,
    public reviews?: Review[],
  ) {
  }
}

export const productListShort = [
  new Product(1, "Gyöngy nyakék", "Kiss Márta", 12599, false, 12, "Azonnal szállítható", "Ékszer", ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["arany", "ásvány"], ["assets/item2.jpg"], "Lorem ipsum", true),
  new Product(2, "Arany lánc", "Nagy Erzsébet", 18599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item1.jpg"], "Lorem ipsum", true),
  new Product(3, "Ásvány medál ékszer", "Széles Lajos", 11999, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item3.jfif"], "Lorem ipsum", true),
  new Product(4, "Arany és kristály nyaklánc", "Közepes Borbála", 19599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item4.jpg"], "Lorem ipsum", true),
];

export const myProductList = [
  new Product(1, "Gyöngy nyakék", "Nagy Erzsébet", 12599, false, 12, "Azonnal szállítható", "Ékszer", ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["arany", "ásvány"], ["assets/item2.jpg"], "Lorem ipsum", false),
  new Product(2, "Arany lánc", "Nagy Erzsébet", 18599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item1.jpg"], "Lorem ipsum", true),
  new Product(3, "Ásvány medál ékszer", "Nagy Erzsébet", 11999, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item3.jfif"], "Lorem ipsum", true),
  new Product(4, "Arany és kristály nyaklánc", "Nagy Erzsébet", 19599, false, 12, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item4.jpg"], "Lorem ipsum", true),
];

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

export const ratingToArray = function(rating:number):number[]{
  let stars:number[] = [];
  for (let index = 0; index < rating; index++) {
    stars.push(index);
  }
  return stars;
}

export const toProductShort = function(product:Product):ProductShort{
  let productShort:ProductShort = {id: product.id, name: product.name, seller: product.seller, price: product.price, discountAvailable: product.discountAvailable, imgUrl:product.imgUrl[0]};
  return productShort;
}


// export const productListLong = [
//     new Product( 1, "Gyöngy nyakék", "Kiss Márta", 12599, false, 12, "Azonnal szállítható", "Ékszer", ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["arany", "ásvány"], ["assets/item2.jpg"], "Lorem ipsum", true),
//     new Product( 2, "Arany lánc", "Nagy Erzsébet", 18599, false, 8, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item1.jpg"], "Lorem ipsum", true),
//     new Product( 3, "Ásvány medál ékszer", "Széles Lajos", 11999, false, 7, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item3.jfif"], "Lorem ipsum", true),
//     new Product( 4, "Arany és kristály nyaklánc", "Közepes Borbála", 19599, false, 5, "Azonnal szállítható", "Ékszer", ["környezetbarát", "kézzel készült"], ["arany", "ásvány"], ["assets/item4.jpg"], "Lorem ipsum", true),
//     new Product( 5, "Őszibarack befőtt", "Kiss Márta", 2599, false, 23, "Azonnal szállítható", "Élelmiszer", ["Vegán", "Bio", "Helyben termesztett"], ["őszibarack", "víz", "cukor"], ["assets/item5.jfif"], "Lorem ipsum", true),
//     new Product( 6, "Egres befőtt", "Szekszárdi Katalin", 2799, false, 17, "Azonnal szállítható", "Élelmiszer", ["Vegán", "Bio", "Helyben termesztett"], ["egres", "víz", "cukor"], ["assets/item6.JPG"], "Lorem ipsum", true),
//     new Product( 7, "Diós és lekváros leveles kiflik", "Szekszárdi Katalin", 1999, false, 17, "Azonnal szállítható", "Élelmiszer", ["Bio", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["tej", "tojás", "cukor", "liszt"], ["assets/item7.jpg"], "Lorem ipsum", true),
//     new Product( 8, "Túrós-fahéjas hajtogatós ", "Szekszárdi Katalin", 1999, false, 17, "Azonnal szállítható", "Élelmiszer", ["Bio", "Kézzel készült", "Etikusan beszerzett alapanyagok"], ["túró", "fahéj", "cukor", "liszt"], ["assets/item8.jpg"], "Lorem ipsum", true),
// ];

// export const productDetailed = new Product(
//     1, "Csodálatos arany nyaklánc medál",
//     "Kiss Márta",
//     12599, false, 12,
//     "Azonnal szállítható",
//     "Ékszer",
//     ["Környezetbarát", "Kézzel készült", "Etikusan beszerzett alapanyagok"],
//     ["arany", "ásvány"],
//     ["assets/item2.jpg", "assets/item1.jpg", "assets/item4.jpg"],
//     "Lorem ipsum dolor sit amet consectetur adipisicing elit. Tempore, quo voluptates nemo dolores at modi ipsam fuga odio architecto beatae aliquid molestiae enim qui obcaecati doloribus. Ex saepe voluptatem magnam!",
//     true, undefined,
//     4.7,
//     //reviews
// );