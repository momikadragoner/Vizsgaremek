import { Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, retry } from 'rxjs/operators';

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
  //reviews?: Review[],
}

@Injectable()
export class ProductService {
  
  constructor(private http: HttpClient) { }
  
  rootURL = '/api';

  getProduct() {
    return this.http.get<Product>(this.rootURL + '/products',);
  }
  
  
}
