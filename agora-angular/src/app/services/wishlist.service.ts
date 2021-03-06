import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { AuthService } from '../account-forms/services/auth.service';

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

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }
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
    return this.http.post<object>(this.rootURL + '/wish-list', wishList, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
      .pipe(
        catchError(error => this.handleError(error))
      );
  }

  deleteWishList(id: number) {
    return this.http.delete(this.rootURL + '/wish-list/' + id, {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${this.authService.getToken()}`
      })
    })
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
