import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders, HttpParams } from '@angular/common/http';
import { HttpErrorResponse, HttpResponse } from '@angular/common/http';

import { Observable, throwError } from 'rxjs';
import { catchError, map, retry } from 'rxjs/operators';
import { AuthService } from '../account-forms/services/auth.service';


@Injectable()
export class PictureService {

  constructor(
    private http: HttpClient,
    private authService: AuthService
  ) { }

  rootURL = '/api';

  currentUserId() {
    return this.authService.getUserDetails()[0].member_id
  }

  addPicture(picture:FormData) {
    return this.http.post<FormData>(this.rootURL + '/picture/product-picture', picture,
    { headers: new HttpHeaders({'Authorization': `Bearer ${this.authService.getToken()}`}) })
      .pipe(
        catchError((error) => this.handleError(error))
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
