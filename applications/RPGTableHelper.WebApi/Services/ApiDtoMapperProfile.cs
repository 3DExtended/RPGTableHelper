using System.CodeDom;
using AutoMapper;
using Prodot.Patterns.Cqrs;
using RPGTableHelper.DataLayer.Contracts.Models.RpgEntities.NoteEntities;
using RPGTableHelper.WebApi.Dtos.RpgEntities;

namespace RPGTableHelper.DataLayer
{
    public class ListOfAbstractBaseTypeConverter<A, T> : IValueConverter<IList<A>, IList<T>>
        where A : class
        where T : A
    {
        public IList<T> Convert(IList<A> source, ResolutionContext context)
        {
            if (source == null)
            {
                return new List<T>();
            }

            return source.Where(x => x.GetType().IsAssignableTo(typeof(T))).Select(x => (T)x).ToList();
        }
    }

    public class ApiDtoMapperProfile : Profile
    {
        public ApiDtoMapperProfile()
        {
            CreateMap<NoteDocumentDto, NoteDocument>()
                .ForMember(dest => dest.NoteBlocks, opt => opt.MapFrom(src => MapNoteBlocks(src)));

            CreateMap<NoteDocument, NoteDocumentDto>()
                .ForMember(
                    x => x.ImageBlocks,
                    opt =>
                        opt.ConvertUsing(
                            new ListOfAbstractBaseTypeConverter<NoteBlockModelBase, ImageBlock>(),
                            x => x.NoteBlocks
                        )
                )
                .ForMember(
                    x => x.TextBlocks,
                    opt =>
                        opt.ConvertUsing(
                            new ListOfAbstractBaseTypeConverter<NoteBlockModelBase, TextBlock>(),
                            x => x.NoteBlocks
                        )
                );
        }

        private static IList<NoteBlockModelBase> MapNoteBlocks(NoteDocumentDto dto)
        {
            var noteBlocks = new List<NoteBlockModelBase>();
            noteBlocks.AddRange(dto.ImageBlocks);
            noteBlocks.AddRange(dto.TextBlocks);
            return noteBlocks;
        }
    }
}
