import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { Review } from './review.service';
import { AuthService } from '../account-forms/services/auth.service';

export interface Product {
  productId: number,
  name: string,
  price: number,
  inventory: number,
  delivery: string,
  category: string,
  sellerFirstName: string,
  sellerLastName: string,
  materials: string[],
  tags: string[],
  imgUrl: string[],
  description: string,
  isPublic: boolean,
  publishedAt?: Date,
  createdAt?: Date,
  lastUpdatedAt?: Date,
  discount?: number,
  rating?: number,
  sellerId?: number,
  reviews: Review[]
}

export interface ProductShort {
  productId: number,
  sellerId?: number,
  name: string,
  sellerFirstName: string,
  sellerLastName: string,
  price: number,
  imgUrl: string,
  isPublic?: boolean,
  discount?: number,
}

@Injectable()
export class ProductService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  rootURL = '/api';

  httpOptions = {
    headers: new HttpHeaders({
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${this.authService.getToken()}`
    })
  };

  httpOptionsFile = {
    headers: new HttpHeaders({
      // 'Content-Type': 'application/json',
      // 'Content-Type': 'multipart/form-daa'
      'Authorization': `Bearer ${this.authService.getToken()}`
    })
  };

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }

  getProduct(id: any) {
    return this.http.get<Product>(this.rootURL + '/product/' + id,)
      .pipe(
        catchError(this.handleError)
      );
  }

  getAllProducts() {
    return this.http.get<[ProductShort]>(this.rootURL + '/products');
  }

  getProducts(type:string) {
    return this.http.get<[ProductShort]>(this.rootURL + '/top-products/' + type)
    .pipe(
      catchError((error) => this.handleError(error))
    );
  }

  getProductsBySeller(id: any, order?: string, term?: string) {
    let params = new HttpParams();

    let options = order && !term ? { params: new HttpParams().set('orderby', order) } :
      order && term ? { params: new HttpParams().set('orderby', order).set('term', term.trim()) } :
        !order && term ? { params: new HttpParams().set('term', term.trim()) } : {};

    return this.http.get<[ProductShort]>(this.rootURL + '/products/seller/' + id, options);
  }

  getMyProducts(order?: string, term?: string) {
    let token = localStorage.getItem('token') ? localStorage.getItem('token') : '';
    let headers = new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` });
    let options = order && !term ? { params: new HttpParams().set('orderby', order), headers: headers } :
      order && term ? { params: new HttpParams().set('orderby', order).set('term', term.trim()), headers: headers } :
        !order && term ? { params: new HttpParams().set('term', term.trim()), headers: headers } : { headers: headers };

    return this.http.get<[ProductShort]>(this.rootURL + '/my-products/' + this.currentUserId(), options);
  }

  addProduct(product: Product): Observable<Product> {
    return this.http.post<Product>(this.rootURL + '/product', product, this.httpOptionsFile)
      .pipe(
        catchError((error) => this.handleError(error))
      );
  }

  deleteProduct(id: number): Observable<unknown> {
    const url = this.rootURL + '/product/' + id;
    return this.http.delete(url, this.httpOptions)
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  updateProduct(product: Product, id: number): Observable<Product> {
    return this.http.put<Product>(this.rootURL + '/product/' + id, product, this.httpOptions)
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  changeVisibility(isPublic: boolean, id: number) {
    let visibility = { "isPublic": isPublic };
    return this.http.put<object>(this.rootURL + '/change-visibility/' + id, visibility, this.httpOptions)
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  searchProducts(queryString: string) {
    return this.http.get<[ProductShort]>(this.rootURL + queryString).pipe(
      catchError(error => this.handleError(error))
    );
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
    return throwError(() =>
      'Something bad happened; please try again later.');
  }

}

export class Product {
  /**
   *
   */
  constructor(
    public productId: number = 0,
    public name: string = "",
    public sellerFirstName: string = "",
    public sellerLastName: string = "",
    public price: number = -1,
    public inventory: number = -1,
    public delivery: string = "",
    public category: string = "",
    public tags: string[] = [""],
    public materials: string[] = [""],
    public imgUrl: string[] = [""],
    public description: string = "",
    public isPublic: boolean = false,
    public reviews: Review[],
    public discount?: number,
    public rating?: number,
  ) {
  }
}

export class ProductShort {
  /**
   *
   */
  constructor(
    public productId: number = 0,
    public name: string = "",
    public sellerFirstName: string = "",
    public sellerLastName: string = "",
    public price: number = -1,
    public imgUrl: string = "",
    public isPublic?: boolean,
    public sellerId?: number,
    public discount?: number
  ) {
  }
}

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

export const categories = [
  "Zöldség",
  "Gyümölcs",
  "Pékáru",
  "Tejtermék",
  "Ital",
  "Ékszer",
  "Művészet",
  "Divat",
  "Kamra",
  "Húsáru"
]

export const ratingToArray = function (rating: number): number[] {
  let stars: number[] = [];
  for (let index = 0; index < rating; index++) {
    stars.push(index);
  }
  return stars;
}
