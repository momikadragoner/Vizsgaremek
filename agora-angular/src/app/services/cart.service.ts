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

    currentUser = this.authService.getUserDetails()[0];
    rootURL = '/api';

    httpOptions = {
        headers: new HttpHeaders({
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${this.authService.getToken()}`
        })
    };

    getCartProducts() {

        return this.http.get<[CartProduct]>(this.rootURL + '/cart-products/' + this.currentUser.member_id, this.httpOptions)
            .pipe(
                catchError(this.handleError)
            );
    }

    getCart() {
        return this.http.get<Cart>(this.rootURL + '/cart/' + this.currentUser.member_id, this.httpOptions)
        .pipe(
            catchError(this.handleError)
        );
    }

    getOrders() {
        return this.http.get<[Cart]>(this.rootURL + '/order/' + this.currentUser.member_id, this.httpOptions)
        .pipe(
            catchError(this.handleError)
        );
    }

    getMyOrders() {
        return this.http.get<[Cart]>(this.rootURL + '/my-orders/' + this.currentUser.member_id, this.httpOptions)
        .pipe(
            catchError(this.handleError)
        );
    }

    postCart(productId: number, userId: number = this.currentUser.member_id) {
        let cart = {
            "productId": productId,
            "userId": userId
        }
        return this.http.post<object>(this.rootURL + '/post-cart', cart, this.httpOptions)
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    sendCart(cart:Cart){
        return this.http.put<object>(this.rootURL + '/put-cart', cart, this.httpOptions)
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    updateCartProducts(cartProducts:CartProduct[]){
        return this.http.put<object>(this.rootURL + '/update-cart-products', cartProducts, this.httpOptions)
        .pipe(
            catchError(error => this.handleError(error))
        );
    }

    deleteCartProduct(id:number) {
        return this.http.delete(this.rootURL + '/delete-cart/' + id, this.httpOptions)
            .pipe(
                catchError(this.handleError)
            );
    }

    deleteCartOrder(cartId:number, userId:number = this.currentUser.member_id){
        return this.http.delete(this.rootURL + '/delete-cart-order/' + cartId + "/" + userId, this.httpOptions)
        .pipe(
            catchError(this.handleError)
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
