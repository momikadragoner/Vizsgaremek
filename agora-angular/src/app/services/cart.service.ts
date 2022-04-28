import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { Address } from './address.service';
import { AuthService } from '../account-forms/services/auth.service';

export interface CartProduct {
  cartProductId: number,
  productId: number,
  sellerId?: number,
  name: string,
  sellerFirstName: string,
  sellerLastName: string,
  price: number,
  imgUrl: string,
  status: string,
  amount: number,
  isPublic?: boolean,
  discount?: number
}

export class CartProduct {
  /**
   *
   */
  constructor(
    public cartProductId: number = 0,
    public productId: number = 0,
    public name: string = "",
    public sellerFirstName: string = "",
    public sellerLastName: string = "",
    public price: number = -1,
    public imgUrl: string = "",
    public status: string = "",
    public amount: number = 0,
    public isPublic?: boolean,
    public sellerId?: number,
    public discount?: number
  ) {
  }
}

export interface Cart {
  cartId: number,
  products: CartProduct[],
  sumPrice: number,
  userId: number,
  shippingId: number,
  status: string,
  address: Address
}

export class Cart {
  /**
   *
   */
  constructor(
    public cartId: number = 0,
    public products: CartProduct[] = [],
    public sumPrice: number = -1,
    public userId: number = 0,
    public shippingId: number = 0,
    public status: string = "",
    public address: Address = new Address()
  ) {
  }
}

@Injectable()
export class CartService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  getToken() {
    return localStorage.getItem('token') ? localStorage.getItem('token') : '';
  }

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }

  rootURL = '/api';

  getCartProducts() {
    return this.http.get<[CartProduct]>(this.rootURL + '/cart-products/' + this.currentUserId(),
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(this.handleError)
      );
  }

  getCart() {
    return this.http.get<Cart>(this.rootURL + '/cart/' + this.currentUserId(),
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(this.handleError)
      );
  }

  getOrders() {
    return this.http.get<[Cart]>(this.rootURL + '/order/' + this.currentUserId(),
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(this.handleError)
      );
  }

  getMyOrders() {
    return this.http.get<[Cart]>(this.rootURL + '/my-orders/' + this.currentUserId(),
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(this.handleError)
      );
  }

  postCart(productId: number, userId: number = this.currentUserId()) {
    let cart = {
      "productId": productId,
      "userId": userId
    }
    return this.http.post<object>(this.rootURL + '/cart', cart,
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  sendCart(cart: Cart) {
    return this.http.put<object>(this.rootURL + '/cart', cart,
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  updateCartProducts(cartProducts: CartProduct[]) {
    return this.http.put<object>(this.rootURL + '/cart-products', cartProducts,
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  deleteCartProduct(id: number) {
    return this.http.delete(this.rootURL + '/cart/' + id,
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(this.handleError)
      );
  }

  deleteCartOrder(cartId: number, userId: number = this.currentUserId()) {
    return this.http.delete(this.rootURL + '/cart-order/' + cartId + "/" + userId,
    { headers: new HttpHeaders({ 'Content-Type': 'application/json', 'Authorization': 'Bearer ' + this.getToken() })})
      .pipe(
        catchError(this.handleError)
      );
  }

  private handleError(error: HttpErrorResponse) {
    if (error.status === 0) {
      console.error('An error occurred:', error.error);
    } else {
      console.error(
        `Backend returned code ${error.status}, body was: `, error.error);
    }
    return throwError(() =>
      'Something bad happened; please try again later.');
  }

}
