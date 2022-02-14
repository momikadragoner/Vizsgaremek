import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { Auth } from './auth';

export interface WishListProduct {
    wishListId: number,
    productId: number,
    sellerId?: number,
    name: string,
    sellerFirstName: string,
    sellerLastName: string,
    price: number,
    imgUrl: string,
    addedAt?: Date,
    isPublic?: boolean,
    discount?: number
}

export class WishListProduct {
    /**
     *
     */
    constructor(
        public wishListId: number = 0,
        public productId: number = 0,
        public name: string = "",
        public sellerFirstName: string = "",
        public sellerLastName: string = "",
        public price: number = -1,
        public imgUrl: string = "",
        public addedAt?: Date,
        public isPublic?: boolean,
        public sellerId?: number,
        public discount?: number
    ) {
    }
}

@Injectable()
export class WishListService {

    constructor(private http: HttpClient) { }

    currentUser = Auth.currentUser;

    rootURL = '/api';

    getWishList(id: number): Observable<[WishListProduct]> {
        return this.http.get<[WishListProduct]>(this.rootURL + "/wish-list/" + id)
            .pipe(
                catchError(error => this.handleError(error))
            );
    }

    postWishList(productId: number, userId: number) {
        let wishList = {
            "productId": productId,
            "userId": userId
        }
        return this.http.post<object>(this.rootURL + '/post-wish-list', wishList)
            .pipe(
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
        return throwError( () =>
          'Something bad happened; please try again later.');
      }

}