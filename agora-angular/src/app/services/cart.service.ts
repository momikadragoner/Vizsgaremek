import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { Auth } from './auth';

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
    status: string
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
        public status: string = ""
    ) {
    }
}

@Injectable()
export class CartService {

    constructor(private http: HttpClient) { }

    currentUser = Auth.currentUser;

    rootURL = '/api';

    httpOptions = {
        headers: new HttpHeaders({
            'Content-Type': 'application/json',
        })
    };

    getCart() {
        return this.http.get<[CartProduct]>(this.rootURL + '/cart/' + this.currentUser.userId,)
            .pipe(
                catchError(this.handleError)
            );
    }

    deleteCart(id: number) {
        return this.http.delete(this.rootURL + '/delete-cart/' + id)
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