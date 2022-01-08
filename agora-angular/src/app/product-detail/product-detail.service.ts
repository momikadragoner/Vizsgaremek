import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';

export interface Review{
  id: number,
  username: string,
  title: string,
  review: string,
  rating: number,
  points: number,
  publishedAt: Date
}

export interface Product{
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
}

export interface ProductShort{
  id: number,
  name: string,
  seller: string,
  price: number,
  discountAvailable: boolean,
  imgUrl: string,
  discount?: number,
}

@Injectable()
export class ProductService {
  
  constructor(private http: HttpClient) { }
  
  rootURL = '/api';

  getProduct() {
    return this.http.get<Product>(this.rootURL + '/product',);
  }

  getReviews() {
    return this.http.get<[Review]>(this.rootURL + '/reviews');
  }

  getProductList() {
    return this.http.get<[ProductShort]>(this.rootURL + '/product-list');
  }

}
