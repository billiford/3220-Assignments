#include <SDL/SDL.h> 
#include <stdio.h> 

void putpixel(SDL_Surface *surface, int x, int y, Uint32 pixel); 
void swap(int*, int*);
void fswap(float*, float*);

int main(int argc, char *argv[]) 
{ 
    SDL_Surface *screen; 
    int quit = 0; 
    SDL_Event event;
    Uint32 white; 

    // Initialize defaults, Video and Audio 
    if((SDL_Init(SDL_INIT_VIDEO)==-1)) 
    { 
        printf("Could not initialize SDL: %s.\n", SDL_GetError()); 
        return -1; 
    } 

    SDL_WM_SetCaption("Line Draw", "Line Draw");
    screen = SDL_SetVideoMode(800, 600, 24, SDL_SWSURFACE );
    if ( screen == NULL ) 
    { 
        fprintf(stderr, "Couldn't set 800x600x24 video mode: %s\n",
				SDL_GetError()); 
        return -2; 
    } 

    // Map the color white to this display (R=0xff, G=0xFF, B=0x00) 
    white = SDL_MapRGB(screen->format, 0xff, 0xff, 0xff); 

    int x1, x2, y1, y2; 
    float dy, dx, x, y, m; 
    x1 = 1; y1 = 10; x2 = 10; y2= 100; 

    printf("draw a line between (%d, %d) to (%d, %d)\n", 
			x1, y1, x2, y2); 

    // Lock the screen for direct access to the pixels 
    if ( SDL_MUSTLOCK(screen) ) 
    { 
        if ( SDL_LockSurface(screen) < 0 ) 
        { 
            fprintf(stderr, "Can't lock screen: %s\n", SDL_GetError()); 
            return -3; 
        } 
    } 

    /* Basic Incremental Algorithm */ 

	if (x2 < x1) {
		swap(&x1, &x2);
		swap(&y1, &y2);
	}

    dy = y2 - y1; 
    dx = x2 - x1; 
    m = dy / dx;

    y = y1; 
	
	if (m > 1) {
		for (y = y1; y < y2; y++) {
			float current_line_end = y + m;
			while (y < current_line_end) putpixel(screen, x, y++, white);
			x++;
		}
	} else {
		for (x = x1; x < x2; x++) {
		    int y_05 = (int)(y + 0.5); 
		    int floor_y_05 = (y_05 > (y + 0.5)) ? y_05 - 1 : y_05;
		    putpixel(screen, x, floor_y_05, white);
		    y += m;
		}
	}

    // Unlock Surface if necessary 
    if ( SDL_MUSTLOCK(screen) ) 
    { 
        SDL_UnlockSurface(screen); 
    } 

    SDL_Flip(screen);


    while( !quit ) 
    { 
        // Poll for events 
        while( SDL_PollEvent( &event ) ) 
        { 
            switch( event.type ) 
            { 
                case SDL_KEYUP: 
                    if(event.key.keysym.sym == SDLK_ESCAPE){ 
                        quit = 1; 
                    } else if (event.key.keysym.sym == SDLK_F1){ 
                        SDL_WM_ToggleFullScreen(screen); // Only on X11 
                    }
                    break; 
                case SDL_QUIT: 
                    quit = 1; 
                    break; 
                default: 
                    break; 
            } 
        } 
    } 

    SDL_Quit(); 

    return 0; 
} 

void putpixel(SDL_Surface *surface, int x, int y, Uint32 pixel) 
{ 
    int bpp = surface->format->BytesPerPixel; 
    // Here p is the address to the pixel we want to set 
    Uint8 *p = (Uint8 *)surface->pixels + y * surface->pitch + x * bpp; 

    switch(bpp) 
    { 
        case 1: 
            *p = pixel; 
            break; 
        case 2: 
            *(Uint16 *)p = pixel; 
            break; 
        case 3: 
            if(SDL_BYTEORDER == SDL_BIG_ENDIAN) 
            { 
                p[0] = (pixel >> 16) & 0xff; 
                p[1] = (pixel >> 8) & 0xff; 
                p[2] = pixel & 0xff; 
            } else { 
                p[0] = pixel & 0xff; 
                p[1] = (pixel >> 8) & 0xff; 
                p[2] = (pixel >> 16) & 0xff; 
            } 
            break; 
        case 4: 
            *(Uint32 *)p = pixel; 
            break; 
    } 
}

void swap(int *a, int *b)
{
   int temp;
 
   temp = *b;
   *b   = *a;
   *a   = temp;   
}

void fswap(float *a, float *b)
{
   float temp;
 
   temp = *b;
   *b   = *a;
   *a   = temp;   
}
