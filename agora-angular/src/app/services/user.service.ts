import { Injectable } from '@angular/core';
import { HttpClient, HttpErrorResponse } from '@angular/common/http';
import { catchError, throwError } from 'rxjs';
import { Auth } from './auth';

export interface User {
  userId: number,
  firstName: string,
  lastName: string,
  following: number,
  followers: number,
  email: string,
  phone: string,
  about: string,
  profileImgUrl: string,
  headerImgUrl: string,
  registeredAt: Date,
  isVendor: boolean,
  isAdmin: boolean,
  companyName?: string,
  siteLocation?: string,
  website?: string,
  takesCustomOrders?: boolean,
  iFollow?: boolean
}

export class User {
  /**
   *
   */
  constructor(
    public userId: number = 0,
    public firstName: string = '',
    public lastName: string = '',
    public following: number = -1,
    public followers: number = -1,
    public email: string = '',
    public phone: string = '',
    public about: string = '',
    public profileImgUrl: string = '',
    public headerImgUrl: string = '',
    public registeredAt: Date = new Date(),
    public isVendor: boolean = false,
    public isAdmin: boolean = false,
    public companyName?: string,
    public siteLocation?: string,
    public website?: string,
    public takesCustomOrders?: boolean,
    public iFollow?: boolean
  ) {
  }
}

export interface UserShort {
  userId: number,
  firstName: string,
  lastName: string,
  about: string,
  profileImgUrl: string,
  companyName?: string,
  takesCustomOrders?: boolean,
  iFollow?: boolean
}

export class UserShort {
  constructor(
    public userId: number = 0,
    public firstName: string = '',
    public lastName: string = '',
    public about: string = '',
    public profileImgUrl: string = '',
    public companyName?: string,
    public takesCustomOrders?: boolean,
    public iFollow?: boolean
  ) {
  }
}

@Injectable()
export class UserService {

  constructor(private http: HttpClient) { }

  currentUser:Auth = Auth.currentUser;
  isLoggedIn = this.currentUser.userId != 0;

  rootURL = '/api';

  getUserShort(id: number) {
    let url = this.isLoggedIn ? this.rootURL + '/user-short-log/' + id + "/" + this.currentUser.userId : this.rootURL + '/user-short/' + id;
    return this.http.get<UserShort>(url)
      .pipe(
        catchError(this.handleError)
      );
  }

  getUser(id: number = Auth.currentUser.userId) {
    let url = this.isLoggedIn ? this.rootURL + '/user-log/' + id + "/" + this.currentUser.userId : this.rootURL + '/user/' + id;
    return this.http.get<User>(url)
      .pipe(
        catchError(this.handleError)
      );
  }

  updateUser(user:User) {
    return this.http.put<object>(this.rootURL + '/update-user', user)
    .pipe(
      catchError(this.handleError)
    );
  }

  getContacts(id: number = Auth.currentUser.userId) {
    return this.http.get<[UserShort]>(this.rootURL + '/contacts/' + id)
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

export const seller = new User(
  1,
  "Nagy", "Erzsébet",
  16, 54,
  "erzsi.nagy@mail.hu",
  "301234567",
  "Sziasztok, Aranyoskák! Erzsi néni vagyok. Szabadidőmben szeretek ékszereket és egyéb apróságokat készíteni. ✨💎",
  "assets/profilepic.jpg",
  "assets/header2.jpg",
  new Date(2021, 11, 2),
  true,
  false,
  undefined,
  "Nagybajcs",
  "erzsiekszer.hu",
  true
)